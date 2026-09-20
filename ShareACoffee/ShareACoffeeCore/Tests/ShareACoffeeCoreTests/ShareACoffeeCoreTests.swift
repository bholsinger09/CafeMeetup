import XCTest
@testable import ShareACoffeeCore

final class ShareACoffeeCoreTests: XCTestCase {
    
    // MARK: - User Model Tests
    func testUserInitialization() {
        let user = User(
            id: "test-id",
            email: "test@example.com",
            fullName: "Test User",
            profileImageURL: nil,
            bio: "Test bio",
            studyInterests: ["Math", "Physics"],
            academicLevel: "Undergraduate",
            location: nil,
            isAcademyMember: false,
            isPremiumUser: false,
            joinedAt: Date()
        )
        
        XCTAssertEqual(user.id, "test-id")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.fullName, "Test User")
    }
    
    // MARK: - Avatar Model Tests
    func testAvatarInitialization() {
        let avatar = Avatar(name: "TestAvatar", backgroundColor: .blue)
        XCTAssertEqual(avatar.name, "TestAvatar")
    }
    
    // MARK: - AppTheme Tests
    func testAppThemeIsPremium() {
        XCTAssertFalse(AppTheme.midnight.isPremium)
        XCTAssertTrue(AppTheme.sunset.isPremium)
    }
    
    func testAppThemeGradientColors() {
        let midnightColors = AppTheme.midnight.gradientColors
        XCTAssertFalse(midnightColors.isEmpty)
    }
    
    // MARK: - ColorExtensions Tests
    func testHexColorInitialization() {
        let color = Color(hex: "FF0000") // Red
        XCTAssertNotNil(color)
    }
    
    // MARK: - Location Model Tests
    func testLocationInitialization() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        XCTAssertEqual(location.latitude, 37.7749)
        XCTAssertEqual(location.longitude, -122.4194)
    }
    
    // MARK: - Course Model Tests
    func testCourseInitialization() {
        let course = Course(
            id: "CS101",
            courseCode: "CS 101",
            courseName: "Intro to CS",
            instructorName: "Dr. Smith"
        )
        XCTAssertEqual(course.id, "CS101")
        XCTAssertEqual(course.courseCode, "CS 101")
    }
    
    // MARK: - AcademicBadges Tests
    func testAcademicBadgesInitialization() {
        let badge = AcademicBadges(
            name: "Honor Student",
            description: "Achieved academic honors",
            imageURL: nil,
            earnedDate: Date()
        )
        XCTAssertEqual(badge.name, "Honor Student")
    }
    
    // MARK: - Achievement Model Tests
    func testAchievementInitialization() {
        let achievement = Achievement(
            id: "ach-1",
            title: "First Meet",
            description: "Attended your first study meetup",
            imageURL: nil,
            badgeColor: .blue,
            earnedAt: Date()
        )
        XCTAssertEqual(achievement.id, "ach-1")
    }
    
    // MARK: - CoffeeBadge Tests
    func testCoffeeBadgeInitialization() {
        let badge = CoffeeBadge(
            id: "cb-1",
            name: "Coffee Connoisseur",
            description: "Visited 10 unique coffee shops"
        )
        XCTAssertEqual(badge.id, "cb-1")
    }
    
    // MARK: - ThemeManager Tests
    func testThemeManagerSharedInstance() {
        let manager = ThemeManager.shared
        XCTAssertNotNil(manager)
    }
    
    func testThemeManagerSetTheme() {
        let manager = ThemeManager.shared
        manager.setTheme(.midnight)
        XCTAssertEqual(manager.currentTheme, .midnight)
    }
}
