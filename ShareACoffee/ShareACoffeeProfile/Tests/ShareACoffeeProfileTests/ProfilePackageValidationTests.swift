import XCTest
@testable import ShareACoffeeProfile
@testable import ShareACoffeeCore
@testable import ShareACoffeeStudy
@testable import ShareACoffeeCoffee

/// Tests to validate Profile package imports and type accessibility
class ProfilePackageValidationTests: XCTestCase {
    
    // MARK: - Model Type Tests
    
    func testAchievementCanAccessUserType() {
        let achievement = Achievement(
            id: "ach123",
            userId: "user1",
            title: "Coffee Explorer",
            description: "Visited 10 coffee shops",
            icon: "cup.and.saucer.fill",
            unlockedDate: Date()
        )
        
        XCTAssertEqual(achievement.title, "Coffee Explorer")
    }
    
    func testCoffeeBadgeCanAccessUserType() {
        let badge = CoffeeBadge(
            id: "badge123",
            userId: "user1",
            badgeType: "barista",
            earnedDate: Date()
        )
        
        XCTAssertEqual(badge.badgeType, "barista")
    }
    
    func testAcademicBadgesCanAccessUserType() {
        let badges = AcademicBadges(
            id: "acad123",
            userId: "user1",
            level: "Master",
            subject: "Computer Science",
            earnedDate: Date()
        )
        
        XCTAssertEqual(badges.level, "Master")
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testAchievementConformsToIdentifiable() {
        let achievement = Achievement(
            id: "ach123",
            userId: "user1",
            title: "Achievement",
            description: "Test",
            icon: "star.fill",
            unlockedDate: Date()
        )
        
        let _: AnyHashable = achievement.id
        XCTAssertNotNil(achievement.id)
    }
    
    func testCoffeeBadgeConformsToIdentifiable() {
        let badge = CoffeeBadge(
            id: "badge123",
            userId: "user1",
            badgeType: "barista",
            earnedDate: Date()
        )
        
        let _: AnyHashable = badge.id
        XCTAssertNotNil(badge.id)
    }
    
    func testAcademicBadgesConformsToIdentifiable() {
        let badges = AcademicBadges(
            id: "acad123",
            userId: "user1",
            level: "Master",
            subject: "CS",
            earnedDate: Date()
        )
        
        let _: AnyHashable = badges.id
        XCTAssertNotNil(badges.id)
    }
    
    // MARK: - Cross-Package Dependency Tests
    
    func testProfilePackageDependsOnCore() {
        let user = User(
            id: "profile-user-123",
            firstName: "Profile",
            lastName: "User",
            email: "profile@test.com",
            profileImageURL: nil,
            bio: "Test profile user",
            academicLevel: .undergraduate,
            favoriteSubjects: ["CS"],
            preferences: [:],
            location: User.Location(latitude: 37.7749, longitude: -122.4194),
            rating: 4.7,
            createdAt: Date()
        )
        
        let achievement = Achievement(
            id: "ach123",
            userId: user.id,
            title: "Profile Creator",
            description: "Created a profile",
            icon: "person.fill",
            unlockedDate: Date()
        )
        
        XCTAssertEqual(achievement.userId, user.id)
    }
    
    func testProfilePackageDependsOnStudyAndCoffee() {
        // Test that Profile can access types from Study package
        let session = StudySession(
            id: "session123",
            hostId: "user1",
            title: "Study Session",
            description: "Test",
            subject: "CS",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            maxParticipants: 5,
            currentParticipants: 1,
            isVirtual: false
        )
        
        // Test that Profile can access types from Coffee package
        let shop = CoffeeShop(
            id: "shop123",
            name: "Test Coffee",
            address: "123 Main",
            city: "SF",
            state: "CA",
            location: User.Location(latitude: 37.7749, longitude: -122.4194),
            rating: 4.5,
            hasWifi: true,
            hasOutlets: true,
            quietRating: 4.0,
            reviewCount: 10
        )
        
        // Verify both are accessible
        XCTAssertNotNil(session)
        XCTAssertNotNil(shop)
    }
    
    // MARK: - Core Type Integration Tests
    
    func testCanCreateUserLocationInProfilePackage() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        XCTAssertEqual(location.latitude, 37.7749)
        XCTAssertEqual(location.longitude, -122.4194)
    }
}
