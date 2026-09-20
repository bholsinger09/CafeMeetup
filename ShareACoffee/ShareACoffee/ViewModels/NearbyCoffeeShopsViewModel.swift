import SwiftUI
import Combine
import CoreLocation
import ShareACoffeeCore
import ShareACoffeeCoffee

/// ViewModel for nearby coffee shops view
@MainActor
public class NearbyCoffeeShopsViewModel: ObservableObject {
    @Published public var coffeeShops: [CoffeeShop] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var userLocation: CLLocationCoordinate2D?
    
    public init() {
        loadCoffeeShops()
    }
    
    public func loadCoffeeShops() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
}
