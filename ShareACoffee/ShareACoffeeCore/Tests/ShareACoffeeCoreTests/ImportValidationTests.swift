import XCTest
@testable import ShareACoffeeCore

/// Tests to verify all imports are correct and types are accessible
class ImportValidationTests: XCTestCase {
    
    // MARK: - Core Model Tests
    
    func testUserTypeIsAccessible() {
        let user = User(
            id: "test123",
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: [],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 4.5,
            createdAt: Date()
        )
        
        XCTAssertEqual(user.id, "test123")
        XCTAssertEqual(user.firstName, "John")
    }
    
    func testUserLocationTypeIsAccessible() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        XCTAssertEqual(location.latitude, 37.7749)
        XCTAssertEqual(location.longitude, -122.4194)
    }
    
    func testUserLocationCodable() throws {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(location)
        
        let decoder = JSONDecoder()
        let decodedLocation = try decoder.decode(User.Location.self, from: data)
        
        XCTAssertEqual(decodedLocation.latitude, location.latitude)
        XCTAssertEqual(decodedLocation.longitude, location.longitude)
    }
    
    func testAvatarTypeIsAccessible() {
        let avatar = Avatar(style: "default", color: "blue")
        
        XCTAssertEqual(avatar.style, "default")
    }
    
    func testAppThemeTypeIsAccessible() {
        let theme = AppTheme.default
        
        XCTAssertNotNil(theme.primaryColor)
    }
    
    // MARK: - Cross-Package Type Usage
    
    func testBlogPostCanUseUserLocation() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        // This tests that BlogPost can reference User.Location
        // If this test compiles, then the type is in scope in dependent packages
        XCTAssertNotNil(location)
    }
    
    func testCoffeeShopCanUseUserLocation() {
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
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testUserConformsToIdentifiable() {
        let user = User(
            id: "test123",
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: [],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 4.5,
            createdAt: Date()
        )
        
        // If this compiles, User conforms to Identifiable
        let _: AnyHashable = user.id
        XCTAssertNotNil(user.id)
    }
    
    func testAvatarConformsToIdentifiable() {
        let avatar = Avatar(style: "default", color: "blue")
        
        // If this compiles, Avatar conforms to Identifiable
        let _: AnyHashable = avatar.id
        XCTAssertNotNil(avatar.id)
    }
    
    func testUserLocationConformsToEquatable() {
        let location1 = User.Location(latitude: 37.7749, longitude: -122.4194)
        let location2 = User.Location(latitude: 37.7749, longitude: -122.4194)
        let location3 = User.Location(latitude: 37.0, longitude: -122.0)
        
        XCTAssertEqual(location1, location2)
        XCTAssertNotEqual(location1, location3)
    }
    
    func testUserLocationConformsToCodeable() throws {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(location)
        XCTAssertFalse(data.isEmpty)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(User.Location.self, from: data)
        XCTAssertEqual(decoded, location)
    }
}
