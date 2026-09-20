import XCTest
@testable import ShareACoffeeDiscovery
import ShareACoffeeCore

final class ShareACoffeeDiscoveryTests: XCTestCase {
    
    func testStudyBuddyRecommendationModelInitialization() {
        let recommendation = StudyBuddyRecommendation(
            id: "rec-1",
            recommendedUserId: "user-123",
            recommendedUserName: "John Doe",
            matchScore: 0.85,
            commonInterests: ["Math", "Physics"]
        )
        XCTAssertEqual(recommendation.id, "rec-1")
        XCTAssertEqual(recommendation.matchScore, 0.85)
    }
    
    func testDiscoveryViewModelExists() {
        let viewModel = DiscoveryViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    func testStudyBuddyRecommendationServiceExists() {
        let service = StudyBuddyRecommendationService.shared
        XCTAssertNotNil(service)
    }
}
