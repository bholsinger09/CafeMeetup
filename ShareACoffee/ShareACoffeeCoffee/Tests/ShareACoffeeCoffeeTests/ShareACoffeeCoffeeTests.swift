import XCTest
@testable import ShareACoffeeCoffee
import ShareACoffeeCore

final class ShareACoffeeCoffeeTests: XCTestCase {
    
    func testCoffeeShopModelInitialization() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        let coffeeShop = CoffeeShop(
            id: "shop-1",
            name: "Brew Haven",
            address: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94105",
            location: location,
            phoneNumber: "(415) 555-1234",
            website: "https://brewhaven.com",
            rating: 4.5,
            priceRange: .moderate,
            amenities: ["WiFi", "Parking", "Quiet Area"],
            hours: nil,
            createdAt: Date()
        )
        XCTAssertEqual(coffeeShop.id, "shop-1")
        XCTAssertEqual(coffeeShop.name, "Brew Haven")
    }
    
    func testCoffeeExperienceServiceExists() {
        let service = CoffeeExperienceService.shared
        XCTAssertNotNil(service)
    }
    
    func testLocationServiceExists() {
        let service = LocationService.shared
        XCTAssertNotNil(service)
    }
    
    func testQRCodeServiceExists() {
        let service = QRCodeService.shared
        XCTAssertNotNil(service)
    }
}
