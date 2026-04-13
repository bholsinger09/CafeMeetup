import Foundation

struct CoffeeShop: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var location: Location
    var phoneNumber: String?
    var website: String?
    var rating: Double?
    var priceRange: PriceRange
    var amenities: [String]
    var hours: [DayHours]?
    var createdAt: Date
    
    // Study Environment Features
    var studyEnvironment: StudyEnvironment?
    var currentlyStudyingCount: Int = 0 // Real-time count
    
    // Distance from user (not persisted, computed on demand)
    var distance: Double? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, city, state, zipCode, location
        case phoneNumber, website, rating, priceRange, amenities, hours, createdAt
        case studyEnvironment, currentlyStudyingCount
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        city: String,
        state: String,
        zipCode: String,
        location: Location,
        phoneNumber: String? = nil,
        website: String? = nil,
        rating: Double? = nil,
        priceRange: PriceRange = .moderate,
        amenities: [String] = [],
        hours: [DayHours]? = nil,
        createdAt: Date = Date(),
        studyEnvironment: StudyEnvironment? = nil,
        currentlyStudyingCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.location = location
        self.phoneNumber = phoneNumber
        self.website = website
        self.rating = rating
        self.priceRange = priceRange
        self.amenities = amenities
        self.hours = hours
        self.createdAt = createdAt
        self.studyEnvironment = studyEnvironment
        self.currentlyStudyingCount = currentlyStudyingCount
    }
    
    // Study-friendly score (0-100)
    var studyScore: Int {
        guard let env = studyEnvironment else { return 50 }
        
        var score = 0
        
        // WiFi speed (40 points)
        switch env.wifiSpeed {
        case .excellent: score += 40
        case .good: score += 30
        case .fair: score += 15
        case .poor: score += 5
        case .none: score += 0
        }
        
        // Noise level (30 points) - quieter is better for studying
        switch env.noiseLevel {
        case .veryQuiet: score += 30
        case .quiet: score += 25
        case .moderate: score += 15
        case .loud: score += 5
        case .veryLoud: score += 0
        }
        
        // Outlets availability (20 points)
        switch env.outletsAvailability {
        case .many: score += 20
        case .some: score += 12
        case .few: score += 6
        case .none: score += 0
        }
        
        // Seating comfort (10 points)
        switch env.seatingComfort {
        case .excellent: score += 10
        case .good: score += 7
        case .fair: score += 4
        case .poor: score += 0
        }
        
        return score
    }
}

// MARK: - Study Environment Rating
struct StudyEnvironment: Codable, Equatable {
    var wifiSpeed: WiFiSpeed
    var noiseLevel: NoiseLevel
    var outletsAvailability: OutletsAvailability
    var seatingComfort: SeatingComfort
    var groupStudyCapacity: Int // Number of tables/areas suitable for groups
    var hasPrivateRooms: Bool
    var bestStudyHours: [String]? // e.g., ["Morning (8am-12pm)", "Afternoon (1pm-5pm)"]
    var studentReviews: Int // Number of student reviews
    
    enum WiFiSpeed: String, Codable {
        case excellent = "Excellent (50+ Mbps)"
        case good = "Good (20-50 Mbps)"
        case fair = "Fair (10-20 Mbps)"
        case poor = "Poor (<10 Mbps)"
        case none = "No WiFi"
    }
    
    enum NoiseLevel: String, Codable {
        case veryQuiet = "Very Quiet"
        case quiet = "Quiet"
        case moderate = "Moderate"
        case loud = "Loud"
        case veryLoud = "Very Loud"
    }
    
    enum OutletsAvailability: String, Codable {
        case many = "Many (Most Tables)"
        case some = "Some (50%+ Tables)"
        case few = "Few (<50% Tables)"
        case none = "None"
    }
    
    enum SeatingComfort: String, Codable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
    }
}

// MARK: - Price Range
enum PriceRange: String, Codable, CaseIterable {
    case budget = "$"
    case moderate = "$$"
    case expensive = "$$$"
    case luxury = "$$$$"
}

// MARK: - Day Hours
struct DayHours: Codable, Equatable {
    let day: String
    let openTime: String
    let closeTime: String
    let isClosed: Bool
    
    init(day: String, openTime: String, closeTime: String, isClosed: Bool = false) {
        self.day = day
        self.openTime = openTime
        self.closeTime = closeTime
        self.isClosed = isClosed
    }
}
