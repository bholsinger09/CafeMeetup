import Foundation
import CoreLocation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var fullName: String
    var college: String
    var state: String
    var city: String
    var favoriteCoffee: String
    var favoriteCoffeeShop: String
    var bio: String?
    var location: Location?
    var profileImageURL: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        email: String,
        fullName: String,
        college: String,
        state: String,
        city: String,
        favoriteCoffee: String,
        favoriteCoffeeShop: String,
        bio: String? = nil,
        location: Location? = nil,
        profileImageURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.college = college
        self.state = state
        self.city = city
        self.favoriteCoffee = favoriteCoffee
        self.favoriteCoffeeShop = favoriteCoffeeShop
        self.bio = bio
        self.location = location
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Location
struct Location: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
