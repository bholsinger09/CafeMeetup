import XCTest
@testable import CafeMeetup

final class UserModelTests: XCTestCase {
    
    func testUserInitialization() {
        let user = User(
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.fullName, "John Doe")
        XCTAssertEqual(user.college, "Test University")
        XCTAssertEqual(user.state, "California")
        XCTAssertEqual(user.city, "Los Angeles")
        XCTAssertEqual(user.favoriteCoffee, "Latte")
        XCTAssertEqual(user.favoriteCoffeeShop, "Starbucks")
        XCTAssertNil(user.bio)
        XCTAssertNil(user.location)
    }
    
    func testUserWithOptionalFields() {
        let location = Location(latitude: 34.0522, longitude: -118.2437)
        
        let user = User(
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks",
            bio: "Coffee lover!",
            location: location
        )
        
        XCTAssertEqual(user.bio, "Coffee lover!")
        XCTAssertNotNil(user.location)
        XCTAssertEqual(user.location?.latitude, 34.0522)
        XCTAssertEqual(user.location?.longitude, -118.2437)
    }
    
    func testUserEquality() {
        let user1 = User(
            id: "123",
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        let user2 = User(
            id: "123",
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        XCTAssertEqual(user1, user2)
    }
}
