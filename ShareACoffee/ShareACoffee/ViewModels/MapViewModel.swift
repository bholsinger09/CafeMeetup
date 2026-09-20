import SwiftUI
import Combine
import MapKit
import ShareACoffeeCore
import ShareACoffeeCoffee

/// ViewModel for map-based features and coffee shop discovery
@MainActor
public class MapViewModel: NSObject, ObservableObject {
    @Published public var coffeeShops: [CoffeeShop] = []
    @Published public var userLocation: CLLocationCoordinate2D?
    @Published public var currentUserLocation: CLLocationCoordinate2D?
    @Published public var users: [User] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    public override init() {
        super.init()
        loadCoffeeShops()
    }
    
    public func loadCoffeeShops() {
        isLoading = true
        // Mock data - in production would load from service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
}
