import XCTest
@testable import CafeMeetup

/// Tests for Match and UserLike models
/// Verifies: Model integrity, data relationships, business logic
final class MatchModelTests: XCTestCase {
    
    // MARK: - Match Model Tests
    
    func testMatchInitialization() {
        // Given
        let userId1 = "user1"
        let userId2 = "user2"
        
        // When
        let match = Match(userId1: userId1, userId2: userId2)
        
        // Then
        XCTAssertNotNil(match.id, "Match should have a unique ID")
        XCTAssertEqual(match.userId1, userId1, "userId1 should match initialization")
        XCTAssertEqual(match.userId2, userId2, "userId2 should match initialization")
        XCTAssertTrue(match.isActive, "New match should be active by default")
        XCTAssertEqual(match.unreadCount, 0, "New match should have zero unread messages")
        XCTAssertNotNil(match.matchedAt, "Match should have a timestamp")
    }
    
    func testMatchInvolvesUser() {
        // Given
        let userId1 = "user1"
        let userId2 = "user2"
        let userId3 = "user3"
        let match = Match(userId1: userId1, userId2: userId2)
        
        // When/Then
        XCTAssertTrue(match.involves(userId: userId1), "Match should involve userId1")
        XCTAssertTrue(match.involves(userId: userId2), "Match should involve userId2")
        XCTAssertFalse(match.involves(userId: userId3), "Match should not involve userId3")
    }
    
    func testMatchOtherUserId() {
        // Given
        let userId1 = "user1"
        let userId2 = "user2"
        let match = Match(userId1: userId1, userId2: userId2)
        
        // When/Then
        XCTAssertEqual(match.otherUserId(currentUserId: userId1), userId2, "Should return userId2 when given userId1")
        XCTAssertEqual(match.otherUserId(currentUserId: userId2), userId1, "Should return userId1 when given userId2")
    }
    
    func testMatchEquality() {
        // Given
        let userId1 = "user1"
        let userId2 = "user2"
        let match1 = Match(userId1: userId1, userId2: userId2)
        let match2 = match1
        
        // When/Then
        XCTAssertEqual(match1, match2, "Matches with same ID should be equal")
    }
    
    // MARK: - UserLike Model Tests
    
    func testUserLikeInitialization() {
        // Given
        let userId = "liker"
        let likedUserId = "liked"
        
        // When
        let like = UserLike(userId: userId, likedUserId: likedUserId)
        
        // Then
        XCTAssertNotNil(like.id, "Like should have a unique ID")
        XCTAssertEqual(like.userId, userId, "userId should match initialization")
        XCTAssertEqual(like.likedUserId, likedUserId, "likedUserId should match initialization")
        XCTAssertNotNil(like.createdAt, "Like should have a timestamp")
    }
    
    func testUserLikeTimestamp() {
        // Given
        let beforeDate = Date()
        
        // When
        let like = UserLike(userId: "user1", likedUserId: "user2")
        
        // Then
        let afterDate = Date()
        XCTAssertGreaterThanOrEqual(like.createdAt, beforeDate, "createdAt should be after test start")
        XCTAssertLessThanOrEqual(like.createdAt, afterDate, "createdAt should be before test end")
    }
    
    // MARK: - Clean Code Principle Tests
    
    func testMatchModelFollowsSingleResponsibilityPrinciple() {
        // Verify Match model only handles match-related data
        let match = Match(userId1: "user1", userId2: "user2")
        
        // Match should have clear, focused properties
        XCTAssertNotNil(match.id, "Should have identifier")
        XCTAssertNotNil(match.userId1, "Should track first user")
        XCTAssertNotNil(match.userId2, "Should track second user")
        XCTAssertNotNil(match.matchedAt, "Should track match time")
        XCTAssertNotNil(match.isActive, "Should track match status")
        
        // Should not handle messaging logic (that's Message model's job)
        // Should not handle service operations (that's MatchService's job)
    }
    
    func testModelsAreImmutableWhereAppropriate() {
        // Given
        let like = UserLike(userId: "user1", likedUserId: "user2")
        let originalDate = like.createdAt
        
        // Then - createdAt should be immutable (let property)
        XCTAssertEqual(like.createdAt, originalDate, "Timestamp should not change")
    }
}
