import Foundation
import MapKit
import Combine

@MainActor
class MapViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @Published var currentUserLocation: Location?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let maxDistanceMiles: Double = 5.0
    
    init(userService: UserServiceProtocol = UserService.shared, locationService: LocationServiceProtocol = LocationService.shared) {
        self.userService = userService
        self.locationService = locationService
    }
    
    func requestLocationPermission() {
        locationService.requestAuthorization()
    }
    
    func centerOnCurrentLocation() async {
        do {
            let coordinate = try await locationService.getCurrentLocation()
            currentUserLocation = Location(coordinate: coordinate)
            print("[MapViewModel] Current location updated: \(coordinate.latitude), \(coordinate.longitude)")
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        } catch {
            print("[MapViewModel] Failed to get current location: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func startTrackingLocation() async {
        print("[MapViewModel] Starting location tracking...")
        // Update current location periodically
        await centerOnCurrentLocation()
    }
    
    func fetchNearbyUsers(city: String, state: String, currentUserId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current location first
            await centerOnCurrentLocation()
            
            // Geocode city and state to get coordinates
            await geocodeLocation(city: city, state: state)
            
            // Fetch all users in the city/state
            var allUsers = try await userService.fetchUsers(inCity: city, state: state)
            
            // Filter out current user
            allUsers = allUsers.filter { $0.id != currentUserId }
            
            // Filter by recently active (within last 30 minutes)
            let recentlyActiveUsers = allUsers.filter { $0.isRecentlyActive }
            
            // Filter by distance (5 miles) if we have current location
            if let currentLocation = currentUserLocation {
                users = recentlyActiveUsers.filter { user in
                    guard let userLocation = user.location else { return false }
                    let distance = currentLocation.distance(to: userLocation)
                    return distance <= maxDistanceMiles
                }
            } else {
                // If no current location, just show recently active users
                users = recentlyActiveUsers
            }
            
            // Center map on first user if available, otherwise keep geocoded location
            if let firstUser = users.first, let location = firstUser.location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func geocodeLocation(city: String, state: String) async {
        let geocoder = CLGeocoder()
        let addressString = "\(city), \(state)"
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(addressString)
            if let coordinate = placemarks.first?.location?.coordinate {
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        } catch {
            // Silently fail and keep default or current region
            print("Failed to geocode \(addressString): \(error.localizedDescription)")
        }
    }
    
    func centerOnUser(_ user: User) {
        guard let location = user.location else { return }
        
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
