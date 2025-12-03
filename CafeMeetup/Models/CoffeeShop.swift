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
        createdAt: Date = Date()
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
