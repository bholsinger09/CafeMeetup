import XCTest
@testable import CafeMeetup

/// Tests for Message model and related types
/// Verifies: Message properties, gift types, icebreaker questions
final class MessageModelTests: XCTestCase {
    
    // MARK: - Message Model Tests
    
    func testMessageInitialization() {
        // Given
        let senderId = "sender123"
        let receiverId = "receiver456"
        let content = "Hello, want to grab coffee?"
        
        // When
        let message = Message(senderId: senderId, receiverId: receiverId, content: content)
        
        // Then
        XCTAssertNotNil(message.id, "Message should have a unique ID")
        XCTAssertEqual(message.senderId, senderId, "senderId should match")
        XCTAssertEqual(message.receiverId, receiverId, "receiverId should match")
        XCTAssertEqual(message.content, content, "content should match")
        XCTAssertNotNil(message.sentAt, "Message should have sent timestamp")
        XCTAssertNil(message.readAt, "New message should not be read")
        XCTAssertFalse(message.isPriority, "Regular message should not be priority")
        XCTAssertNil(message.giftType, "Regular message should not have gift")
    }
    
    func testPriorityMessage() {
        // Given/When
        let message = Message(
            senderId: "user1",
            receiverId: "user2",
            content: "Important message",
            isPriority: true
        )
        
        // Then
        XCTAssertTrue(message.isPriority, "Priority flag should be set")
    }
    
    func testGiftMessage() {
        // Given/When
        let message = Message(
            senderId: "user1",
            receiverId: "user2",
            content: "Sent you a gift!",
            giftType: .coffee
        )
        
        // Then
        XCTAssertEqual(message.giftType, .coffee, "Gift type should be set")
        XCTAssertTrue(message.isGift, "isGift computed property should be true")
    }
    
    func testMessageReadStatus() {
        // Given
        var message = Message(senderId: "user1", receiverId: "user2", content: "Test")
        
        // When - Message initially unread
        XCTAssertNil(message.readAt, "New message should not have readAt")
        XCTAssertFalse(message.isRead, "New message should not be read")
        
        // When - Mark as read
        message.readAt = Date()
        
        // Then
        XCTAssertNotNil(message.readAt, "Read message should have readAt timestamp")
        XCTAssertTrue(message.isRead, "Message with readAt should be read")
    }
    
    // MARK: - GiftType Tests
    
    func testAllGiftTypesHaveEmoji() {
        // Given/When/Then
        for giftType in GiftType.allCases {
            XCTAssertFalse(giftType.emoji.isEmpty, "\(giftType) should have an emoji")
            XCTAssertFalse(giftType.displayName.isEmpty, "\(giftType) should have a display name")
        }
    }
    
    func testGiftTypeCount() {
        // Given/When
        let giftCount = GiftType.allCases.count
        
        // Then
        XCTAssertEqual(giftCount, 6, "Should have exactly 6 gift types")
    }
    
    func testGiftTypeEmojis() {
        // Verify specific emoji assignments
        XCTAssertEqual(GiftType.coffee.emoji, "☕️", "Coffee should have coffee emoji")
        XCTAssertEqual(GiftType.heart.emoji, "❤️", "Heart should have heart emoji")
        XCTAssertEqual(GiftType.rose.emoji, "🌹", "Rose should have rose emoji")
        XCTAssertEqual(GiftType.cake.emoji, "🎂", "Cake should have cake emoji")
        XCTAssertEqual(GiftType.star.emoji, "⭐️", "Star should have star emoji")
        XCTAssertEqual(GiftType.sparkles.emoji, "✨", "Sparkles should have sparkles emoji")
    }
    
    // MARK: - IcebreakerQuestion Tests
    
    func testIcebreakerQuestionsExist() {
        // Given/When
        let questions = IcebreakerQuestion.questions
        
        // Then
        XCTAssertFalse(questions.isEmpty, "Should have icebreaker questions")
        XCTAssertGreaterThanOrEqual(questions.count, 10, "Should have at least 10 questions")
    }
    
    func testIcebreakerQuestionsAreUnique() {
        // Given
        let questions = IcebreakerQuestion.questions
        
        // When
        let uniqueQuestions = Set(questions)
        
        // Then
        XCTAssertEqual(questions.count, uniqueQuestions.count, "All questions should be unique")
    }
    
    func testIcebreakerQuestionsAreNotEmpty() {
        // Given/When/Then
        for question in IcebreakerQuestion.questions {
            XCTAssertFalse(question.isEmpty, "Question should not be empty")
            XCTAssertTrue(question.count > 10, "Question should be meaningful (>10 chars)")
        }
    }
    
    func testRandomIcebreakerQuestion() {
        // Given/When
        let question1 = IcebreakerQuestion.random()
        let question2 = IcebreakerQuestion.random()
        
        // Then
        XCTAssertFalse(question1.isEmpty, "Random question should not be empty")
        XCTAssertTrue(IcebreakerQuestion.questions.contains(question1), "Random should return valid question")
        
        // Note: There's a small chance they could be the same, but that's OK for randomness
    }
    
    // MARK: - Clean Code Principle Tests
    
    func testMessageModelHasClearResponsibility() {
        // Message model should only handle message data, not business logic
        let message = Message(senderId: "s", receiverId: "r", content: "test")
        
        // Should have data properties
        XCTAssertNotNil(message.id)
        XCTAssertNotNil(message.senderId)
        XCTAssertNotNil(message.receiverId)
        XCTAssertNotNil(message.content)
        
        // Should have computed properties for convenience
        _ = message.isRead
        _ = message.isGift
        
        // Should NOT handle:
        // - Sending logic (that's MessageService)
        // - UI rendering (that's Views)
        // - Persistence (that's Services)
    }
    
    func testEnumTypesAreWellDefined() {
        // GiftType should be exhaustive and clear
        XCTAssertGreaterThanOrEqual(GiftType.allCases.count, 5, "Should have multiple gift options")
        
        // Each should have clear metadata
        for gift in GiftType.allCases {
            XCTAssertFalse(gift.emoji.isEmpty, "Each gift needs emoji")
            XCTAssertFalse(gift.displayName.isEmpty, "Each gift needs name")
        }
    }
    
    func testMessageTimestampsFollowLogicalOrder() {
        // Given
        let message = Message(senderId: "s", receiverId: "r", content: "test")
        let sentTime = message.sentAt
        
        // When
        sleep(1)
        var updatedMessage = message
        updatedMessage.readAt = Date()
        
        // Then
        if let readTime = updatedMessage.readAt {
            XCTAssertGreaterThan(readTime, sentTime, "Read time should be after sent time")
        }
    }
    
    func testMessageConformsToProtocols() {
        // Message should conform to standard protocols
        let message = Message(senderId: "s", receiverId: "r", content: "test")
        
        // Should be Identifiable
        XCTAssertNotNil(message.id, "Should have Identifiable protocol")
        
        // Should be Codable (for persistence/networking)
        XCTAssertNotNil(try? JSONEncoder().encode(message), "Should be Codable")
        
        // Should be Equatable
        let message2 = message
        XCTAssertEqual(message, message2, "Should be Equatable")
    }
}
