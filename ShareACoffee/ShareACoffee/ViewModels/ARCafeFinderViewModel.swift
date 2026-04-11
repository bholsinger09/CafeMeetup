import Foundation
import ARKit
import CoreLocation
import Combine

/// AR Cafe Location - Enhanced cafe model for AR navigation
struct ARCafeLocation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    var distance: Double // meters
    var bearing: Double? // degrees from north
    var isVisible: Bool = false
    var currentOccupancy: Int = 0
    var activeSessionsCount: Int = 0
    
    var directionDescription: String {
        guard let bearing = bearing else { return "Unknown direction" }
        
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((bearing + 22.5) / 45.0) % 8
        return directions[index]
    }
    
    init(from coffeeShop: CoffeeShop, userLocation: CLLocationCoordinate2D) {
        self.id = coffeeShop.id
        self.name = coffeeShop.name
        self.coordinate = CLLocationCoordinate2D(
            latitude: coffeeShop.location.latitude,
            longitude: coffeeShop.location.longitude
        )
        
        // Calculate distance
        let shopLocation = CLLocation(latitude: coffeeShop.location.latitude, longitude: coffeeShop.location.longitude)
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        self.distance = shopLocation.distance(from: userLoc)
        
        // Calculate bearing
        self.bearing = userLoc.bearing(to: shopLocation)
    }
}

/// ViewModel for AR Cafe Finder
class ARCafeFinderViewModel: NSObject, ObservableObject {
    @Published var nearbyCafes: [ARCafeLocation] = []
    @Published var selectedCafe: ARCafeLocation?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isARSupported: Bool = false
    
    var arView: ARSCNView?
    
    private var userLocation: CLLocationCoordinate2D
    private var locationManager: CLLocationManager
    private var headingSubscriber: AnyCancellable?
    private var currentHeading: Double = 0
    
    init(cafes: [CoffeeShop], userLocation: CLLocationCoordinate2D) {
        self.userLocation = userLocation
        self.locationManager = CLLocationManager()
        
        super.init()
        
        // Check AR support
        self.isARSupported = ARWorldTrackingConfiguration.isSupported
        
        // Convert cafes to AR locations
        self.nearbyCafes = cafes
            .map { ARCafeLocation(from: $0, userLocation: userLocation) }
            .filter { $0.distance < 5000 } // Only show cafes within 5km
            .sorted { $0.distance < $1.distance }
        
        setupLocationTracking()
        loadCafeOccupancyData()
    }
    
    // MARK: - AR Session Management
    
    func startARSession() {
        guard isARSupported else {
            errorMessage = "AR is not supported on this device"
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    func stopARSession() {
        arView?.session.pause()
    }
    
    func handleARError(_ error: Error) {
        errorMessage = "AR Error: \(error.localizedDescription)"
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Location Tracking
    
    private func setupLocationTracking() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func updateUserLocation(_ location: CLLocationCoordinate2D) {
        userLocation = location
        
        // Recalculate distances and bearings
        for index in nearbyCafes.indices {
            let shopLocation = CLLocation(
                latitude: nearbyCafes[index].coordinate.latitude,
                longitude: nearbyCafes[index].coordinate.longitude
            )
            let userLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            nearbyCafes[index].distance = shopLocation.distance(from: userLoc)
            nearbyCafes[index].bearing = userLoc.bearing(to: shopLocation)
        }
        
        // Re-sort by distance
        nearbyCafes.sort { $0.distance < $1.distance }
    }
    
    func updateHeading(_ heading: Double) {
        currentHeading = heading
    }
    
    // MARK: - AR Position Calculations
    
    func calculateARPosition(for cafe: ARCafeLocation) -> SCNVector3? {
        guard let bearing = cafe.bearing else { return nil }
        
        // Convert bearing to radians
        let bearingRadians = (bearing - currentHeading) * .pi / 180.0
        
        // Scale distance for AR (1 meter in AR = actual distance / 100)
        let scaledDistance = Float(min(cafe.distance / 100.0, 50.0))
        
        // Calculate position
        let x = Float(sin(bearingRadians)) * scaledDistance
        let z = -Float(cos(bearingRadians)) * scaledDistance
        let y = Float(0.5) // Slightly above ground
        
        return SCNVector3(x, y, z)
    }
    
    func updateCafeVisibility(cameraTransform: simd_float4x4) {
        let cameraDirection = simd_make_float3(cameraTransform.columns.2)
        
        for index in nearbyCafes.indices {
            if let position = calculateARPosition(for: nearbyCafes[index]) {
                let cafeDirection = simd_normalize(simd_make_float3(position.x, 0, position.z))
                let dot = simd_dot(
                    simd_normalize(simd_make_float3(cameraDirection.x, 0, cameraDirection.z)),
                    cafeDirection
                )
                
                // Cafe is visible if it's in front of camera (dot > 0.3 = ~70 degree FOV)
                nearbyCafes[index].isVisible = dot > 0.3
            }
        }
    }
    
    // MARK: - Cafe Selection
    
    func selectCafe(_ cafe: ARCafeLocation) {
        selectedCafe = cafe
    }
    
    func navigateToCafe(_ cafe: ARCafeLocation) {
        // Open in Maps app
        let coordinate = cafe.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = cafe.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    // MARK: - Load Real-time Data
    
    private func loadCafeOccupancyData() {
        // Load real-time occupancy and active sessions from Firebase
        for index in nearbyCafes.indices {
            let cafeId = nearbyCafes[index].id
            
            // Mock data for now - in production, fetch from Firebase
            nearbyCafes[index].currentOccupancy = Int.random(in: 0...15)
            nearbyCafes[index].activeSessionsCount = Int.random(in: 0...5)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ARCafeFinderViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateUserLocation(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateHeading(newHeading.trueHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location Error: \(error.localizedDescription)"
    }
}

// MARK: - CLLocation Extension for Bearing

extension CLLocation {
    func bearing(to destination: CLLocation) -> Double {
        let lat1 = latitude * .pi / 180.0
        let lon1 = longitude * .pi / 180.0
        let lat2 = destination.latitude * .pi / 180.0
        let lon2 = destination.longitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)
        
        let bearingDegrees = bearing * 180.0 / .pi
        return (bearingDegrees + 360.0).truncatingRemainder(dividingBy: 360.0)
    }
}

// MARK: - MapKit Import

import MapKit
