import Foundation
import CoreLocation

public struct User: Identifiable, Codable, Equatable {
    public let id: String
    public var email: String
    public var fullName: String
    public var college: String
    public var state: String
    public var city: String
    public var country: String // Country user lives in
    public var address: String?
    public var favoriteCoffee: String
    public var favoriteCoffeeShop: String
    public var bio: String?
    public var gender: String?
    public var location: User.Location?
    public var profileImageURL: String?
    public var lastActiveAt: Date?
    public var avatarId: String?
    public var preferredLanguage: String // Language preference for the app
    public var createdAt: Date
    public var updatedAt: Date
    
    // Academic profile
    public var major: String?
    public var graduationYear: Int?
    public var currentCourses: [String]? // Course IDs
    public var isTutor: Bool = false
    public var tutorSubjects: [String]? // Subjects user can tutor
    public var studyHoursThisWeek: Int = 0
    public var totalStudySessions: Int = 0
    public var studyStreak: Int = 0 // Days in a row with study activity
    public var totalStudyHours: Int = 0 // Lifetime study hours
    
    // Customization & Aesthetics
    public var selectedTheme: String? // Theme preference (AppTheme.rawValue)
    public var isPremiumUser: Bool = false
    
    // Privacy & Testing
    public var isTestUser: Bool = false // Indicates if this is a sample/demo user for testing
    
    public init(
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
        location: User.Location? = nil,
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
        studyStreak: Int = 0,
        totalStudyHours: Int = 0,
        selectedTheme: String? = nil,
        isPremiumUser: Bool = false,
        isTestUser: Bool = false
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
        self.totalStudyHours = totalStudyHours
        self.selectedTheme = selectedTheme
        self.isPremiumUser = isPremiumUser
        self.isTestUser = isTestUser
    }
    
    // Helper to check if user is recently active (within last 30 minutes)
    public var isRecentlyActive: Bool {
        guard let lastActive = lastActiveAt else { return false }
        return Date().timeIntervalSince(lastActive) < 1800 // 30 minutes
    }
    
    // Get the user's selected avatar
    public var avatar: Avatar {
        if let avatarId = avatarId, let avatar = AvatarSystem.avatar(withId: avatarId) {
            return avatar
        }
        return AvatarSystem.defaultAvatar
    }
    
    // Academic year display
    public var academicYear: String? {
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
    
    // MARK: - Nested Location Type
    public struct Location: Codable, Equatable {
        public let latitude: Double
        public let longitude: Double
        
        public var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        public init(coordinate: CLLocationCoordinate2D) {
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
        
        // Calculate distance in miles to another location
        public func distance(to other: Location) -> Double {
            let from = CLLocation(latitude: latitude, longitude: longitude)
            let to = CLLocation(latitude: other.latitude, longitude: other.longitude)
            let distanceMeters = from.distance(from: to)
            return distanceMeters / 1609.34 // Convert meters to miles
        }
    }
}
