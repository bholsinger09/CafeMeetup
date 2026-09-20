import XCTest
@testable import ShareACoffeeSocial
@testable import ShareACoffeeCore

/// Tests to validate Social package imports and type accessibility
class SocialPackageValidationTests: XCTestCase {
    
    // MARK: - Type Accessibility Tests
    
    func testMatchCanAccessUserType() {
        let match = Match(
            id: "match123",
            userId: "user1",
            matchedUserId: "user2",
            matchPercentage: 85.0,
            commonInterests: ["coffee", "studying"],
            matchDate: Date()
        )
        
        XCTAssertEqual(match.matchPercentage, 85.0)
    }
    
    func testMessageCanAccessUserType() {
        let message = Message(
            id: "msg123",
            senderId: "user1",
            recipientId: "user2",
            content: "Hello!",
            timestamp: Date(),
            isRead: false
        )
        
        XCTAssertEqual(message.content, "Hello!")
        XCTAssertFalse(message.isRead)
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testMatchConformsToIdentifiable() {
        let match = Match(
            id: "match123",
            userId: "user1",
            matchedUserId: "user2",
            matchPercentage: 85.0,
            commonInterests: [],
            matchDate: Date()
        )
        
        let _: AnyHashable = match.id
        XCTAssertNotNil(match.id)
    }
    
    func testMessageConformsToIdentifiable() {
        let message = Message(
            id: "msg123",
            senderId: "user1",
            recipientId: "user2",
            content: "Test",
            timestamp: Date(),
            isRead: false
        )
        
        let _: AnyHashable = message.id
        XCTAssertNotNil(message.id)
    }
    
    // MARK: - Service Tests
    
    func testMatchServiceHasUserTypeAccess() {
        let service = MatchService()
        XCTAssertNotNil(service)
    }
    
    func testMessageServiceHasUserTypeAccess() {
        let service = MessageService()
        XCTAssertNotNil(service)
    }
    
    // MARK: - Cross-Package Tests
    
    func testSocialPackageDependsOnCore() {
        let user = User(
            id: "social-user-123",
            firstName: "Social",
            lastName: "User",
            email: "social@test.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: [],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 4.5,
            createdAt: Date()
        )
        
        let match = Match(
            id: "match123",
            userId: user.id,
            matchedUserId: "other-user",
            matchPercentage: 85.0,
            commonInterests: [],
            matchDate: Date()
        )
        
        XCTAssertEqual(match.userId, user.id)
    }
}
