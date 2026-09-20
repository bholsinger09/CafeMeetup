import XCTest
@testable import ShareACoffeeDiscovery
@testable import ShareACoffeeCore
@testable import ShareACoffeeSocial

/// Tests to validate Discovery package imports and type accessibility
class DiscoveryPackageValidationTests: XCTestCase {
    
    // MARK: - Type Accessibility Tests
    
    func testStudyBuddyRecommendationCanAccessUserType() {
        let recommendation = StudyBuddyRecommendation(
            id: "rec123",
            userId: "user1",
            recommendedUserId: "user2",
            compatibilityScore: 0.85,
            commonInterests: ["CS", "Math"],
            recommendationDate: Date()
        )
        
        XCTAssertEqual(recommendation.compatibilityScore, 0.85)
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testStudyBuddyRecommendationConformsToIdentifiable() {
        let recommendation = StudyBuddyRecommendation(
            id: "rec123",
            userId: "user1",
            recommendedUserId: "user2",
            compatibilityScore: 0.85,
            commonInterests: [],
            recommendationDate: Date()
        )
        
        let _: AnyHashable = recommendation.id
        XCTAssertNotNil(recommendation.id)
    }
    
    // MARK: - ViewModel Tests
    
    func testDiscoveryViewModelCanAccessCoreTypes() {
        let viewModel = DiscoveryViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    func testStudyBuddyRecommendationViewModelCanAccessCoreTypes() {
        let viewModel = StudyBuddyRecommendationViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - Cross-Package Tests
    
    func testDiscoveryPackageDependsOnCoreAndSocial() {
        let user1 = User(
            id: "user1",
            firstName: "Discovery",
            lastName: "User1",
            email: "user1@test.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: ["CS"],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 4.5,
            createdAt: Date()
        )
        
        let user2 = User(
            id: "user2",
            firstName: "Discovery",
            lastName: "User2",
            email: "user2@test.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: ["CS"],
            preferences: [:],
            location: User.Location(latitude: 1.0, longitude: 1.0),
            rating: 4.6,
            createdAt: Date()
        )
        
        let recommendation = StudyBuddyRecommendation(
            id: "rec123",
            userId: user1.id,
            recommendedUserId: user2.id,
            compatibilityScore: 0.85,
            commonInterests: ["CS"],
            recommendationDate: Date()
        )
        
        XCTAssertEqual(recommendation.userId, user1.id)
        XCTAssertEqual(recommendation.recommendedUserId, user2.id)
    }
}
