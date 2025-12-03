import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func requestAuthorization()
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

class LocationService: NSObject, LocationServiceProtocol, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocationCoordinate2D?
    
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
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
        guard let location = locations.last else { return }
        
        currentLocation = location.coordinate
        
        if let continuation = locationContinuation {
            continuation.resume(returning: location.coordinate)
            locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let continuation = locationContinuation {
            continuation.resume(throwing: LocationError.unableToGetLocation)
            locationContinuation = nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
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
