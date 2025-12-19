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
    
    // MARK: - Avatar Tests
    
    func testUserAvatarWithValidAvatarId() {
        // Given
        let user = User(
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks",
            avatarId: "batman"
        )
        
        // When
        let avatar = user.avatar
        
        // Then
        XCTAssertEqual(avatar.id, "batman")
        XCTAssertEqual(avatar.category, .dc)
    }
    
    func testUserAvatarWithNilAvatarIdReturnsDefault() {
        // Given
        let user = User(
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks",
            avatarId: nil
        )
        
        // When
        let avatar = user.avatar
        
        // Then
        XCTAssertEqual(avatar, AvatarSystem.defaultAvatar)
    }
    
    func testUserAvatarWithInvalidAvatarIdReturnsDefault() {
        // Given
        let user = User(
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks",
            avatarId: "invalid-avatar-id-12345"
        )
        
        // When
        let avatar = user.avatar
        
        // Then
        XCTAssertEqual(avatar, AvatarSystem.defaultAvatar)
    }
    
    func testUserAvatarIdPersistsInCoding() {
        // Given
        let user = User(
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks",
            avatarId: "wednesday"
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        do {
            let data = try encoder.encode(user)
            let decodedUser = try decoder.decode(User.self, from: data)
            
            // Then
            XCTAssertEqual(decodedUser.avatarId, "wednesday")
            XCTAssertEqual(decodedUser.avatar.id, "wednesday")
        } catch {
            XCTFail("User with avatarId should be Codable: \(error)")
        }
    }
    
    func testUserCanChangeAvatar() {
        // Given
        var user = User(
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks",
            avatarId: "spiderman"
        )
        
        // When
        XCTAssertEqual(user.avatar.id, "spiderman")
        
        user.avatarId = "batman"
        
        // Then
        XCTAssertEqual(user.avatar.id, "batman")
    }
    
    func testMultipleUsersCanHaveDifferentAvatars() {
        // Given
        let user1 = User(
            email: "user1@example.com",
            fullName: "User One",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks",
            avatarId: "spiderman"
        )
        
        let user2 = User(
            email: "user2@example.com",
            fullName: "User Two",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Cappuccino",
            favoriteCoffeeShop: "Local Cafe",
            avatarId: "batman"
        )
        
        // Then
        XCTAssertNotEqual(user1.avatar, user2.avatar)
        XCTAssertEqual(user1.avatar.id, "spiderman")
        XCTAssertEqual(user2.avatar.id, "batman")
    }
}
