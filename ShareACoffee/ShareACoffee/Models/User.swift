import Foundation
import CoreLocation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var fullName: String
    var college: String
    var state: String
    var city: String
    var country: String // Country user lives in
    var address: String?
    var favoriteCoffee: String
    var favoriteCoffeeShop: String
    var bio: String?
    var gender: String?
    var location: Location?
    var profileImageURL: String?
    var lastActiveAt: Date?
    var avatarId: String?
    var preferredLanguage: String // Language preference for the app
    var createdAt: Date
    var updatedAt: Date
    
    // Academic profile
    var major: String?
    var graduationYear: Int?
    var currentCourses: [String]? // Course IDs
    var isTutor: Bool = false
    var tutorSubjects: [String]? // Subjects user can tutor
    var studyHoursThisWeek: Int = 0
    var totalStudySessions: Int = 0
    var studyStreak: Int = 0 // Days in a row with study activity
    
    init(
        id: String = UUID().uuidString,
        email: String,
        fullName: String,
        college: String,
        state: String,
        city: String,
        country: String = "United States",
        address: String? = nil,
        favoriteCoffee: String,
        favoriteCoffeeShop: String,
        bio: String? = nil,
        gender: String? = nil,
        location: Location? = nil,
        profileImageURL: String? = nil,
        lastActiveAt: Date? = nil,
        avatarId: String? = nil,
        preferredLanguage: String = "en",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        major: String? = nil,
        graduationYear: Int? = nil,
        currentCourses: [String]? = nil,
        isTutor: Bool = false,
        tutorSubjects: [String]? = nil,
        studyHoursThisWeek: Int = 0,
        totalStudySessions: Int = 0,
        studyStreak: Int = 0
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.college = college
        self.state = state
        self.city = city
        self.country = country
        self.address = address
        self.favoriteCoffee = favoriteCoffee
        self.favoriteCoffeeShop = favoriteCoffeeShop
        self.bio = bio
        self.gender = gender
        self.location = location
        self.profileImageURL = profileImageURL
        self.lastActiveAt = lastActiveAt
        self.avatarId = avatarId
        self.preferredLanguage = preferredLanguage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.major = major
        self.graduationYear = graduationYear
        self.currentCourses = currentCourses
        self.isTutor = isTutor
        self.tutorSubjects = tutorSubjects
        self.studyHoursThisWeek = studyHoursThisWeek
        self.totalStudySessions = totalStudySessions
        self.studyStreak = studyStreak
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
    
    // Academic year display
    var academicYear: String? {
        guard let year = graduationYear else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearsRemaining = year - currentYear
        
        switch yearsRemaining {
        case 0: return "Senior (Graduating \(year))"
        case 1: return "Junior (Class of \(year))"
        case 2: return "Sophomore (Class of \(year))"
        case 3: return "Freshman (Class of \(year))"
        default: return "Class of \(year)"
        }
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
