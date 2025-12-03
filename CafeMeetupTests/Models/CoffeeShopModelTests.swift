import XCTest
@testable import CafeMeetup

final class CoffeeShopModelTests: XCTestCase {
    
    func testCoffeeShopInitialization() {
        let location = Location(latitude: 34.0522, longitude: -118.2437)
        
        let shop = CoffeeShop(
            name: "Starbucks",
            address: "123 Main St",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90001",
            location: location
        )
        
        XCTAssertEqual(shop.name, "Starbucks")
        XCTAssertEqual(shop.address, "123 Main St")
        XCTAssertEqual(shop.city, "Los Angeles")
        XCTAssertEqual(shop.state, "CA")
        XCTAssertEqual(shop.zipCode, "90001")
        XCTAssertEqual(shop.location.latitude, 34.0522)
        XCTAssertEqual(shop.priceRange, .moderate)
        XCTAssertEqual(shop.amenities, [])
    }
    
    func testCoffeeShopWithOptionalFields() {
        let location = Location(latitude: 34.0522, longitude: -118.2437)
        let hours = [
            DayHours(day: "Monday", openTime: "7:00 AM", closeTime: "9:00 PM"),
            DayHours(day: "Tuesday", openTime: "7:00 AM", closeTime: "9:00 PM")
        ]
        
        let shop = CoffeeShop(
            name: "Local Café",
            address: "456 Coffee Ave",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90002",
            location: location,
            phoneNumber: "555-1234",
            website: "https://localcafe.com",
            rating: 4.5,
            priceRange: .expensive,
            amenities: ["WiFi", "Outdoor Seating"],
            hours: hours
        )
        
        XCTAssertEqual(shop.phoneNumber, "555-1234")
        XCTAssertEqual(shop.website, "https://localcafe.com")
        XCTAssertEqual(shop.rating, 4.5)
        XCTAssertEqual(shop.priceRange, .expensive)
        XCTAssertEqual(shop.amenities.count, 2)
        XCTAssertEqual(shop.hours?.count, 2)
    }
    
    func testPriceRangeValues() {
        XCTAssertEqual(PriceRange.budget.rawValue, "$")
        XCTAssertEqual(PriceRange.moderate.rawValue, "$$")
        XCTAssertEqual(PriceRange.expensive.rawValue, "$$$")
        XCTAssertEqual(PriceRange.luxury.rawValue, "$$$$")
    }
    
    func testDayHours() {
        let hours = DayHours(day: "Monday", openTime: "8:00 AM", closeTime: "5:00 PM")
        
        XCTAssertEqual(hours.day, "Monday")
        XCTAssertEqual(hours.openTime, "8:00 AM")
        XCTAssertEqual(hours.closeTime, "5:00 PM")
        XCTAssertFalse(hours.isClosed)
    }
    
    func testDayHoursClosed() {
        let hours = DayHours(day: "Sunday", openTime: "", closeTime: "", isClosed: true)
        
        XCTAssertTrue(hours.isClosed)
    }
}
