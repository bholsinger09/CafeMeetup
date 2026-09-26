import SwiftUI
import Combine
import ARKit
import SceneKit
import CoreLocation
import ShareACoffeeCore
import ShareACoffeeCoffee

/// ViewModel for managing AR-based cafe finder experience
@MainActor
public class ARCafeFinderViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published public var nearbyCafes: [ARCafeLocation] = []
    @Published public var selectedCafe: ARCafeLocation?
    @Published public var isARSupported = ARWorldTrackingConfiguration.isSupported
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var userLocation: CLLocationCoordinate2D?
    
    // AR View reference
    var arView: ARSCNView?
    
    private let locationManager = CLLocationManager()
    private var cafes: [CoffeeShop] = []
    private var userHeading: CLHeading?
    
    public init(cafes: [CoffeeShop], userLocation: CLLocationCoordinate2D) {
        super.init()
        self.cafes = cafes
        self.userLocation = userLocation
        self.nearbyCafes = cafes.map { ARCafeLocation(from: $0, userLocation: userLocation) }
            .sorted { $0.distance < $1.distance }
        
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingHeading()
    }
    
    public func startARSession() {
        guard isARSupported else {
            errorMessage = "AR is not supported on this device"
            return
        }
        isLoading = false
    }
    
    public func stopARSession() {
        locationManager.stopUpdatingHeading()
    }
    
    public func selectCafe(_ cafe: ARCafeLocation) {
        selectedCafe = cafe
    }
    
    public func navigateToCafe(_ cafe: ARCafeLocation) {
        // In a real app, this would open Maps or start navigation
        print("Navigating to \(cafe.name)")
    }
    
    public func updateCafeVisibility(cameraTransform: simd_float4x4) {
        // Update which cafes are visible based on camera position
        // This is called from ARSession delegate
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeading = newHeading
        updateCafeBearings()
    }
    
    private func updateCafeBearings() {
        guard let userLoc = userLocation, let heading = userHeading else { return }
        
        for i in 0..<nearbyCafes.count {
            let cafe = nearbyCafes[i]
            let cafeLoc = cafe.coordinate
            
            let userCLLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            let cafeCLLoc = CLLocation(latitude: cafeLoc.latitude, longitude: cafeLoc.longitude)
            
            let bearing = calculateBearing(from: userCLLoc, to: cafeCLLoc)
            let relativeBearing = bearing - heading.trueHeading
            
            nearbyCafes[i].bearing = normalizeAngle(relativeBearing)
        }
    }
    
    private func calculateBearing(from: CLLocation, to: CLLocation) -> Double {
        let lat1 = from.coordinate.latitude.degreesToRadians
        let lon1 = from.coordinate.longitude.degreesToRadians
        let lat2 = to.coordinate.latitude.degreesToRadians
        let lon2 = to.coordinate.longitude.degreesToRadians
        
        let dlon = lon2 - lon1
        let y = sin(dlon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon)
        
        let bearing = atan2(y, x).radiansToDegrees
        return normalizeAngle(bearing)
    }
    
    private func normalizeAngle(_ angle: Double) -> Double {
        var normalized = angle.truncatingRemainder(dividingBy: 360.0)
        if normalized < 0 {
            normalized += 360.0
        }
        return normalized
    }
    
    // MARK: - AR Methods
    
    public func calculateARPosition(for cafe: ARCafeLocation) -> SCNVector3 {
        let distance = Float(cafe.distance) / 1000.0 // Convert to approximate scene units
        let bearing = Float((cafe.bearing ?? 0) * .pi / 180.0)
        
        let x = distance * sin(bearing)
        let z = -distance * cos(bearing)
        
        return SCNVector3(x, 0, z)
    }
    
    public func updateCafeVisibility() {
        guard let heading = userHeading else { return }
        
        for i in 0..<nearbyCafes.count {
            let cafe = nearbyCafes[i]
            guard let bearing = cafe.bearing else { continue }
            
            let angleDiff = abs(bearing - heading.trueHeading)
            nearbyCafes[i].isVisible = angleDiff < 30.0 // Show cafes within 30 degrees
        }
    }
    
    public func handleARError(_ error: Error) {
        errorMessage = error.localizedDescription
        stopARSession()
    }
    
    public func clearError() {
        errorMessage = nil
    }
}

// MARK: - Double Extensions for angle conversion

private extension Double {
    var degreesToRadians: Double {
        self * .pi / 180.0
    }
    
    var radiansToDegrees: Double {
        self * 180.0 / .pi
    }
}
