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
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchNearbyUsers(city: String, state: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Geocode city and state to get coordinates
            await geocodeLocation(city: city, state: state)
            
            users = try await userService.fetchUsers(inCity: city, state: state)
            
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
