import Foundation
import CoreLocation
import ShareACoffeeCore
import ShareACoffeeCoffee

/// AR-optimized representation of a coffee shop location for augmented reality visualization
public struct ARCafeLocation: Identifiable {
    public let id: String
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    public let distance: Double  // in meters
    public let address: String
    public let currentOccupancy: Int
    public let activeSessionsCount: Int
    public let studyEnvironmentRating: Double
    public let amenities: [String]
    public let imageURL: String?
    public var bearing: Double?  // angle in degrees from user to cafe
    public var isVisible: Bool = true  // whether cafe is currently visible in AR view
    public var directionDescription: String {
        guard let bearing = bearing else { return "Behind you" }
        switch bearing {
        case 0...45: return "North"
        case 45...90: return "Northeast"
        case 90...135: return "East"
        case 135...180: return "Southeast"
        case 180...225: return "South"
        case 225...270: return "Southwest"
        case 270...315: return "West"
        default: return "Northwest"
        }
    }
    
    /// Initialize from a CoffeeShop model
    public init(
        from coffeeShop: CoffeeShop,
        userLocation: CLLocationCoordinate2D
    ) {
        self.id = coffeeShop.id
        self.name = coffeeShop.name
        self.coordinate = CLLocationCoordinate2D(
            latitude: coffeeShop.location.latitude,
            longitude: coffeeShop.location.longitude
        )
        
        // Calculate distance in meters
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let shopLoc = CLLocation(latitude: coffeeShop.location.latitude, longitude: coffeeShop.location.longitude)
        self.distance = userLoc.distance(from: shopLoc)
        
        self.address = coffeeShop.address
        self.currentOccupancy = 0  // Would be populated from real-time data
        self.activeSessionsCount = 0  // Would be populated from real-time data
        self.studyEnvironmentRating = Double(coffeeShop.studyEnvironment?.studentReviews ?? 0)
        self.amenities = coffeeShop.amenities
        self.imageURL = nil
        self.bearing = nil
        self.isVisible = self.distance < 1000  // within 1km
    }
    
    /// Direct initialization for testing or manual creation
    public init(
        id: String,
        name: String,
        coordinate: CLLocationCoordinate2D,
        distance: Double,
        address: String,
        currentOccupancy: Int = 0,
        activeSessionsCount: Int = 0,
        studyEnvironmentRating: Double = 0.0,
        amenities: [String] = [],
        imageURL: String? = nil,
        bearing: Double? = nil,
        isVisible: Bool = true
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.distance = distance
        self.address = address
        self.currentOccupancy = currentOccupancy
        self.activeSessionsCount = activeSessionsCount
        self.studyEnvironmentRating = studyEnvironmentRating
        self.amenities = amenities
        self.imageURL = imageURL
        self.bearing = bearing
        self.isVisible = isVisible
    }
}
