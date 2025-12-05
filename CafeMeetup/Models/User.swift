import Foundation
import CoreLocation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var fullName: String
    var college: String
    var major: String? // Academic major for study matching
    var graduationYear: Int? // For age/stage matching
    var state: String
    var city: String
    var favoriteCoffee: String
    var favoriteCoffeeShop: String
    var bio: String?
    var location: Location?
    var profileImageURL: String?
    var createdAt: Date
    var updatedAt: Date
    var studyPreferences: [String]? // Subjects interested in studying
    
    init(
        id: String = UUID().uuidString,
        email: String,
        fullName: String,
        college: String,
        major: String? = nil,
        graduationYear: Int? = nil,
        state: String,
        city: String,
        favoriteCoffee: String,
        favoriteCoffeeShop: String,
        bio: String? = nil,
        location: Location? = nil,
        profileImageURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        studyPreferences: [String]? = nil
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.college = college
        self.major = major
        self.graduationYear = graduationYear
        self.state = state
        self.city = city
        self.favoriteCoffee = favoriteCoffee
        self.favoriteCoffeeShop = favoriteCoffeeShop
        self.bio = bio
        self.location = location
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.studyPreferences = studyPreferences
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
