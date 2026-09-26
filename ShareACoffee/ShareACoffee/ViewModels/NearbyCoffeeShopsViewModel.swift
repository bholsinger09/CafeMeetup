import SwiftUI
import Combine
import CoreLocation
import ShareACoffeeCore
import ShareACoffeeCoffee

/// ViewModel for nearby coffee shops view
@MainActor
public class NearbyCoffeeShopsViewModel: ObservableObject {
    @Published public var coffeeShops: [CoffeeShop] = []
    @Published public var nearbyCoffeeShops: [CoffeeShop] = []
    @Published public var isLoading = false
    @Published public var isRequestingPermission = false
    @Published public var errorMessage: String?
    @Published public var userLocation: CLLocationCoordinate2D?
    @Published public var cacheTimestamp: Date?
    
    public init() {
        loadCoffeeShops()
    }
    
    public func loadCoffeeShops() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
    
    public func checkLocationPermissionAndFetch() {
        isRequestingPermission = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isRequestingPermission = false
            self?.loadCoffeeShops()
        }
    }
    
    public func requestLocationPermission() {
        isRequestingPermission = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isRequestingPermission = false
        }
    }
    
    public func fetchNearbyCoffeeShops() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        isLoading = false
        cacheTimestamp = Date()
    }
}
