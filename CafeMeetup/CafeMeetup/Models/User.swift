import Foundation
import CoreLocation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var fullName: String
    var college: String
    var state: String
    var city: String
    var address: String?
    var favoriteCoffee: String
    var favoriteCoffeeShop: String
    var bio: String?
    var gender: String?
    var relationshipStatus: String?
    var location: Location?
    var profileImageURL: String?
    var lastActiveAt: Date?
    var avatarId: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        email: String,
        fullName: String,
        college: String,
        state: String,
        city: String,
        address: String? = nil,
        favoriteCoffee: String,
        favoriteCoffeeShop: String,
        bio: String? = nil,
        gender: String? = nil,
        relationshipStatus: String? = nil,
        location: Location? = nil,
        profileImageURL: String? = nil,
        lastActiveAt: Date? = nil,
        avatarId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.college = college
        self.state = state
        self.city = city
        self.address = address
        self.favoriteCoffee = favoriteCoffee
        self.favoriteCoffeeShop = favoriteCoffeeShop
        self.bio = bio
        self.gender = gender
        self.relationshipStatus = relationshipStatus
        self.location = location
        self.profileImageURL = profileImageURL
        self.lastActiveAt = lastActiveAt
        self.avatarId = avatarId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Helper to check if user is recently active (within last 30 minutes)
    var isRecentlyActive: Bool {
        guard let lastActive = lastActiveAt else { return false }
        return Date().timeIntervalSince(lastActive) < 1800 // 30 minutes
    }
    
    // Get the user's selected avatar
    var avatar: Avatar {
        if let avatarId = avatarId, let avatar = AvatarSystem.avatar(withId: avatarId) {
            return avatar
        }
        return AvatarSystem.defaultAvatar
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
    
    // Calculate distance in miles to another location
    func distance(to other: Location) -> Double {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: other.latitude, longitude: other.longitude)
        let distanceMeters = from.distance(from: to)
        return distanceMeters / 1609.34 // Convert meters to miles
    }
}
