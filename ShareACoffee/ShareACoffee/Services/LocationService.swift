import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    func requestAuthorization()
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

class LocationService: NSObject, LocationServiceProtocol, ObservableObject {
    nonisolated(unsafe) static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocationCoordinate2D?
    
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
        print("[LocationService] Initialized with authorization status: \(authorizationStatus.rawValue)")
    }
    
    func requestAuthorization() {
        print("[LocationService] Requesting authorization, current status: \(authorizationStatus.rawValue)")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        print("[LocationService] getCurrentLocation called, auth status: \(locationManager.authorizationStatus.rawValue)")
        
        // Check authorization status
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("[LocationService] Location not determined, requesting authorization")
            throw LocationError.unauthorized
        case .restricted, .denied:
            print("[LocationService] Location access denied or restricted")
            throw LocationError.unauthorized
        case .authorizedWhenInUse, .authorizedAlways:
            print("[LocationService] Location authorized, requesting location...")
        @unknown default:
            print("[LocationService] Unknown authorization status")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[LocationService] didUpdateLocations called with \(locations.count) locations")
        guard let location = locations.last else {
            print("[LocationService] No location in array")
            return
        }
        
        print("[LocationService] Got location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        currentLocation = location.coordinate
        
        if let continuation = locationContinuation {
            print("[LocationService] Resuming continuation with location")
            continuation.resume(returning: location.coordinate)
            locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationService] Location manager failed with error: \(error.localizedDescription)")
        if let continuation = locationContinuation {
            continuation.resume(throwing: LocationError.unableToGetLocation)
            locationContinuation = nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let oldStatus = authorizationStatus
        authorizationStatus = manager.authorizationStatus
        print("[LocationService] Authorization changed from \(oldStatus.rawValue) to \(authorizationStatus.rawValue)")
    }
}

// MARK: - Location Errors
enum LocationError: LocalizedError {
    case unableToGetLocation
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .unableToGetLocation:
            return "Unable to get your current location."
        case .unauthorized:
            return "Location access is not authorized. Please enable it in Settings."
        }
    }
}
