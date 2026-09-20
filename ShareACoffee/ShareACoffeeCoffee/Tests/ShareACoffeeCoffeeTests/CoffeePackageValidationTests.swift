import XCTest
@testable import ShareACoffeeCoffee
@testable import ShareACoffeeCore

/// Tests to validate Coffee package imports and type accessibility
class CoffeePackageValidationTests: XCTestCase {
    
    // MARK: - Type Accessibility Tests
    
    func testCoffeeShopCanAccessUserLocation() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        let shop = CoffeeShop(
            id: "shop123",
            name: "Test Coffee",
            address: "123 Main St",
            city: "San Francisco",
            state: "CA",
            location: location,
            rating: 4.5,
            hasWifi: true,
            hasOutlets: true,
            quietRating: 4.0,
            reviewCount: 10
        )
        
        XCTAssertEqual(shop.location.latitude, 37.7749)
        XCTAssertEqual(shop.location.longitude, -122.4194)
    }
    
    func testCoffeeShopLocationIsUserLocation() {
        // Verify that CoffeeShop.location is of type User.Location, not a different Location type
        let location = User.Location(latitude: 40.7128, longitude: -74.0060)
        let shop = CoffeeShop(
            id: "shop456",
            name: "NYC Coffee",
            address: "456 Broadway",
            city: "New York",
            state: "NY",
            location: location,
            rating: 4.8,
            hasWifi: true,
            hasOutlets: true,
            quietRating: 3.5,
            reviewCount: 25
        )
        
        // This test ensures no type mismatch between CoffeeShop.location and User.Location
        XCTAssertEqual(type(of: shop.location), type(of: location))
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testCoffeeShopConformsToIdentifiable() {
        let shop = CoffeeShop(
            id: "shop123",
            name: "Test Coffee",
            address: "123 Main St",
            city: "San Francisco",
            state: "CA",
            location: User.Location(latitude: 37.7749, longitude: -122.4194),
            rating: 4.5,
            hasWifi: true,
            hasOutlets: true,
            quietRating: 4.0,
            reviewCount: 10
        )
        
        let _: AnyHashable = shop.id
        XCTAssertNotNil(shop.id)
    }
    
    func testCoffeeShopConformsToCodable() throws {
        let shop = CoffeeShop(
            id: "shop123",
            name: "Test Coffee",
            address: "123 Main St",
            city: "San Francisco",
            state: "CA",
            location: User.Location(latitude: 37.7749, longitude: -122.4194),
            rating: 4.5,
            hasWifi: true,
            hasOutlets: true,
            quietRating: 4.0,
            reviewCount: 10
        )
        
        // Test Encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(shop)
        XCTAssertFalse(data.isEmpty)
        
        // Test Decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CoffeeShop.self, from: data)
        XCTAssertEqual(decoded.id, shop.id)
        XCTAssertEqual(decoded.name, shop.name)
    }
    
    // MARK: - Service Tests
    
    func testLocationServiceHasUserTypeAccess() {
        let service = LocationService()
        XCTAssertNotNil(service)
    }
    
    func testQRCodeServiceHasUserTypeAccess() {
        let service = QRCodeService()
        XCTAssertNotNil(service)
    }
    
    // MARK: - Cross-Package Tests
    
    func testCoffeePackageDependsOnCore() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        let shop = CoffeeShop(
            id: "shop123",
            name: "Test Coffee",
            address: "123 Main St",
            city: "San Francisco",
            state: "CA",
            location: location,
            rating: 4.5,
            hasWifi: true,
            hasOutlets: true,
            quietRating: 4.0,
            reviewCount: 10
        )
        
        XCTAssertNotNil(shop)
        XCTAssertEqual(shop.location.latitude, location.latitude)
    }
    
    // MARK: - Type Conflict Prevention Tests
    
    func testNoLocationTypeConflict() {
        // Ensure that there's no confusion between User.Location and any other Location type
        let userLocation = User.Location(latitude: 37.7749, longitude: -122.4194)
        let shop = CoffeeShop(
            id: "shop123",
            name: "Test",
            address: "123 Main",
            city: "SF",
            state: "CA",
            location: userLocation,
            rating: 4.5,
            hasWifi: true,
            hasOutlets: true,
            quietRating: 4.0,
            reviewCount: 10
        )
        
        // If this works, there's no type conflict
        XCTAssertEqual(shop.location, userLocation)
    }
}
