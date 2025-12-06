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
    
    convenience init() {
        self.init(userService: UserService.shared, locationService: LocationService.shared)
    }
    
    init(userService: UserServiceProtocol, locationService: LocationServiceProtocol) {
        self.userService = userService
        self.locationService = locationService
        
        // Listen for sign-out events
        NotificationCenter.default.publisher(for: .userDidSignOut)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.resetState()
                }
            }
            .store(in: &cancellables)
    }
    
    func resetState() {
        users = []
        currentUserLocation = nil
        isLoading = false
        errorMessage = nil
        // Reset to default region
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        print("[MapViewModel] State reset")
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
            // Get current location first and keep region centered there
            await centerOnCurrentLocation()
            
            // DEBUG: Check all users in UserService
            let allStoredUsers = userService.getAllUsers()
            print("[MapViewModel] DEBUG: Total users in UserService: \(allStoredUsers.count)")
            
            // Fetch all users in the city/state
            var allUsers = try await userService.fetchUsers(inCity: city, state: state)
            print("[MapViewModel] Found \(allUsers.count) users in \(city), \(state)")
            print("[MapViewModel] Current user ID to filter: '\(currentUserId)'")
            for user in allUsers {
                print("[MapViewModel]   - User: \(user.fullName) (ID: '\(user.id)')")
            }
            
            // Filter out current user
            allUsers = allUsers.filter { $0.id != currentUserId }
            print("[MapViewModel] After filtering current user (\(currentUserId)): \(allUsers.count) users")
            
            // Filter by recently active (within last 30 minutes)
            let recentlyActiveUsers = allUsers.filter { $0.isRecentlyActive }
            print("[MapViewModel] Recently active users: \(recentlyActiveUsers.count)")
            for user in recentlyActiveUsers {
                print("[MapViewModel]   - \(user.fullName): lastActive=\(user.lastActiveAt?.description ?? "nil"), hasLocation=\(user.location != nil)")
            }
            
            // Filter by distance (5 miles) if we have current location
            if let currentLocation = currentUserLocation {
                users = recentlyActiveUsers.filter { user in
                    guard let userLocation = user.location else {
                        print("[MapViewModel] User \(user.fullName) has no location")
                        return false
                    }
                    let distance = currentLocation.distance(to: userLocation)
                    print("[MapViewModel] User \(user.fullName) is \(String(format: "%.2f", distance)) miles away")
                    return distance <= maxDistanceMiles
                }
                print("[MapViewModel] Found \(users.count) nearby users within \(maxDistanceMiles) miles")
            } else {
                // If no current location, just show recently active users
                users = recentlyActiveUsers
                print("[MapViewModel] No current location, showing \(users.count) recently active users")
            }
            
            // Keep map centered on current user's location (don't override)
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
