import Foundation
import MapKit
import Combine

@MainActor
class MapViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var nearbyCoffeeShops: [CoffeeShop] = []
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
        // Use MKLocalSearch instead of deprecated CLGeocoder
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "\(city), \(state)"
        
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            // Access coordinate through location property to avoid deprecated placemark
            if let location = response.mapItems.first?.location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        } catch {
            // Silently fail and keep default or current region
            print("Failed to geocode \(city), \(state): \(error.localizedDescription)")
        }
    }
    
    func centerOnUser(_ user: User) {
        guard let location = user.location else { return }
        
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    // MARK: - Coffee Shop Management
    
    func fetchNearbyCoffeeShops() async {
        print("[MapViewModel] Fetching nearby coffee shops...")
        
        guard let userLocation = currentUserLocation else {
            print("[MapViewModel] No user location available for coffee shop search")
            return
        }
        
        let searchRadius: CLLocationDistance = 24140 // 15 miles in meters
        let region = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: searchRadius * 2,
            longitudinalMeters: searchRadius * 2
        )
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "coffee shop"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            print("[MapViewModel] Found \(response.mapItems.count) coffee shops")
            
            let shops = response.mapItems.compactMap { mapItem -> CoffeeShop? in
                guard let name = mapItem.name else {
                    return nil
                }
                
                let location = mapItem.placemark.location
                guard let location = location else {
                    return nil
                }
                
                // Calculate distance
                let shopLocation = CLLocation(latitude: location.coordinate.latitude,
                                             longitude: location.coordinate.longitude)
                let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude,
                                               longitude: userLocation.coordinate.longitude)
                let distanceMeters = userCLLocation.distance(from: shopLocation)
                let distanceMiles = distanceMeters / 1609.34
                
                // Only include shops within 15 miles
                guard distanceMiles <= 15.0 else { return nil }
                
                var shop = CoffeeShop(
                    name: name,
                    address: mapItem.placemark.thoroughfare ?? "",
                    city: mapItem.placemark.locality ?? "",
                    state: mapItem.placemark.administrativeArea ?? "",
                    zipCode: mapItem.placemark.postalCode ?? "",
                    location: Location(coordinate: location.coordinate),
                    phoneNumber: mapItem.phoneNumber,
                    website: mapItem.url?.absoluteString
                )
                shop.distance = distanceMiles
                
                return shop
            }
            
            nearbyCoffeeShops = shops.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
            print("[MapViewModel] Displaying \(nearbyCoffeeShops.count) coffee shops within 15 miles")
            
        } catch {
            print("[MapViewModel] Failed to fetch coffee shops: \(error.localizedDescription)")
        }
    }
}
