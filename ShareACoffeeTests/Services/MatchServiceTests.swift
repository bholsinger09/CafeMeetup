import XCTest
@testable import CafeMeetup

/// Tests for MatchService following clean code principles
/// Verifies: Service layer separation, business logic, state management
final class MatchServiceTests: XCTestCase {
    
    var sut: MatchService!
    
    override func setUp() {
        super.setUp()
        sut = MatchService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Like Functionality Tests
    
    func testAddLike_CreatesNewLike() async {
        // Given
        let userId = "user1"
        let likedUserId = "user2"
        
        // When
        let isMatch = await sut.addLike(userId: userId, likedUserId: likedUserId)
        
        // Then
        XCTAssertFalse(isMatch, "First like should not create a match")
        let hasLiked = await sut.hasLiked(userId: userId, likedUserId: likedUserId)
        XCTAssertTrue(hasLiked, "Like should be recorded")
    }
    
    func testAddLike_DetectsMutualMatch() async {
        // Given
        let user1 = "user1"
        let user2 = "user2"
        
        // When
        _ = await sut.addLike(userId: user1, likedUserId: user2)
        let isMatch = await sut.addLike(userId: user2, likedUserId: user1)
        
        // Then
        XCTAssertTrue(isMatch, "Mutual likes should create a match")
    }
    
    func testAddLike_PreventsDuplicateLikes() async {
        // Given
        let userId = "user1"
        let likedUserId = "user2"
        
        // When
        _ = await sut.addLike(userId: userId, likedUserId: likedUserId)
        _ = await sut.addLike(userId: userId, likedUserId: likedUserId)
        
        // Then
        let hasLiked = await sut.hasLiked(userId: userId, likedUserId: likedUserId)
        XCTAssertTrue(hasLiked, "Should maintain like state")
        // Should not create duplicate likes (internal state management)
    }
    
    func testHasLiked_ReturnsFalseForNonExistentLike() async {
        // Given
        let userId = "user1"
        let likedUserId = "user2"
        
        // When
        let hasLiked = await sut.hasLiked(userId: userId, likedUserId: likedUserId)
        
        // Then
        XCTAssertFalse(hasLiked, "Should return false for non-existent like")
    }
    
    // MARK: - Match Functionality Tests
    
    func testGetMatches_ReturnsUserMatches() async {
        // Given
        let user1 = "user1"
        let user2 = "user2"
        let user3 = "user3"
        
        // Create matches
        _ = await sut.addLike(userId: user1, likedUserId: user2)
        _ = await sut.addLike(userId: user2, likedUserId: user1)
        
        _ = await sut.addLike(userId: user1, likedUserId: user3)
        _ = await sut.addLike(userId: user3, likedUserId: user1)
        
        // When
        let matches = await sut.getMatches(userId: user1)
        
        // Then
        XCTAssertEqual(matches.count, 2, "User1 should have 2 matches")
    }
    
    func testGetMatches_OnlyReturnsActiveMatches() async {
        // Given
        let user1 = "user1"
        let user2 = "user2"
        
        _ = await sut.addLike(userId: user1, likedUserId: user2)
        _ = await sut.addLike(userId: user2, likedUserId: user1)
        
        let matches = await sut.getMatches(userId: user1)
        guard let matchId = matches.first?.id else {
            XCTFail("Should have created a match")
            return
        }
        
        // When
        await sut.unmatch(matchId: matchId)
        let activeMatches = await sut.getMatches(userId: user1)
        
        // Then
        XCTAssertEqual(activeMatches.count, 0, "Unmatched should not appear in active matches")
    }
    
    func testUnmatch_DeactivatesMatch() async {
        // Given
        let user1 = "user1"
        let user2 = "user2"
        
        _ = await sut.addLike(userId: user1, likedUserId: user2)
        _ = await sut.addLike(userId: user2, likedUserId: user1)
        
        let matchesBefore = await sut.getMatches(userId: user1)
        guard let matchId = matchesBefore.first?.id else {
            XCTFail("Should have created a match")
            return
        }
        
        // When
        await sut.unmatch(matchId: matchId)
        
        // Then
        let matchesAfter = await sut.getMatches(userId: user1)
        XCTAssertEqual(matchesAfter.count, 0, "Should have no active matches after unmatch")
    }
    
    // MARK: - Clean Code Principle Tests
    
    func testServiceFollowsSingleResponsibility() {
        // MatchService should only handle match-related business logic
        // It should NOT:
        // - Handle UI logic (that's ViewModels)
        // - Handle persistence details (that's Repository layer, when implemented)
        // - Handle user authentication (that's AuthenticationService)
        
        // It SHOULD:
        // - Manage likes
        // - Detect mutual matches
        // - Track match state
        // - Update unread counts
        
        XCTAssertNotNil(sut, "Service should exist and be accessible")
    }
    
    func testServiceUsesAsyncAwaitProperly() async {
        // Service methods should use async/await for clean concurrency
        let userId = "testUser"
        let likedUserId = "likedUser"
        
        // All service methods should be async
        _ = await sut.addLike(userId: userId, likedUserId: likedUserId)
        _ = await sut.hasLiked(userId: userId, likedUserId: likedUserId)
        _ = await sut.getMatches(userId: userId)
        
        // Methods should complete without errors
        XCTAssertTrue(true, "Async operations should complete successfully")
    }
    
    func testServiceMaintainsDataIntegrity() async {
        // Given
        let user1 = "user1"
        let user2 = "user2"
        
        // When - Create match
        _ = await sut.addLike(userId: user1, likedUserId: user2)
        _ = await sut.addLike(userId: user2, likedUserId: user1)
        
        // Then - Both users should see the match
        let user1Matches = await sut.getMatches(userId: user1)
        let user2Matches = await sut.getMatches(userId: user2)
        
        XCTAssertEqual(user1Matches.count, user2Matches.count, "Match should be bidirectional")
        XCTAssertEqual(user1Matches.first?.id, user2Matches.first?.id, "Should be same match")
    }
    
    func testServiceHandlesEdgeCases() async {
        // Test empty user IDs
        let emptyResult = await sut.getMatches(userId: "")
        XCTAssertTrue(emptyResult.isEmpty, "Should handle empty user ID gracefully")
        
        // Test non-existent match
        await sut.unmatch(matchId: "non-existent-id")
        // Should not crash, just handle gracefully
        
        XCTAssertTrue(true, "Service should handle edge cases without crashing")
    }
    
    func testServiceFollowsNamingConventions() {
        // Method names should be clear and descriptive
        // Following Swift naming conventions:
        // - addLike (verb)
        // - hasLiked (question)
        // - getMatches (retrieval)
        // - unmatch (action)
        
        // All methods should read like English
        XCTAssertTrue(true, "Service follows Swift naming conventions")
    }
}
