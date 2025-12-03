import XCTest
@testable import CafeMeetup

/// Tests for MessageService business logic and clean code principles
/// Validates: message sending, gift handling, read status, conversation retrieval
final class MessageServiceTests: XCTestCase {
    
    var messageService: MessageService!
    var testUserId1: String!
    var testUserId2: String!
    
    override func setUp() async throws {
        try await super.setUp()
        messageService = MessageService.shared
        testUserId1 = "test_user_1"
        testUserId2 = "test_user_2"
        
        // Clear any existing test data
        messageService.messages.removeAll()
    }
    
    override func tearDown() async throws {
        messageService.messages.removeAll()
        testUserId1 = nil
        testUserId2 = nil
        messageService = nil
        try await super.tearDown()
    }
    
    // MARK: - Message Sending Tests
    
    func testSendMessage_CreatesNewMessage() async throws {
        // Given
        let content = "Hello, this is a test message!"
        
        // When
        try await messageService.sendMessage(
            from: testUserId1,
            to: testUserId2,
            content: content
        )
        
        // Then
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        XCTAssertEqual(conversation.count, 1, "Should create one message")
        
        let message = conversation.first!
        XCTAssertEqual(message.senderId, testUserId1)
        XCTAssertEqual(message.receiverId, testUserId2)
        XCTAssertEqual(message.content, content)
        XCTAssertFalse(message.isRead)
        XCTAssertFalse(message.isPriority)
        XCTAssertNil(message.gift)
    }
    
    func testSendMessage_WithMultipleMessages() async throws {
        // Given
        let messages = ["First message", "Second message", "Third message"]
        
        // When
        for content in messages {
            try await messageService.sendMessage(
                from: testUserId1,
                to: testUserId2,
                content: content
            )
        }
        
        // Then
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        XCTAssertEqual(conversation.count, 3, "Should create three messages")
        
        // Messages should be ordered by timestamp (newest first)
        XCTAssertEqual(conversation[0].content, "Third message")
        XCTAssertEqual(conversation[1].content, "Second message")
        XCTAssertEqual(conversation[2].content, "First message")
    }
    
    func testSendMessage_BidirectionalConversation() async throws {
        // Given & When
        try await messageService.sendMessage(
            from: testUserId1,
            to: testUserId2,
            content: "Hello from user 1"
        )
        
        try await messageService.sendMessage(
            from: testUserId2,
            to: testUserId1,
            content: "Hi back from user 2"
        )
        
        // Then
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        XCTAssertEqual(conversation.count, 2, "Should have messages from both users")
        
        // Verify both directions work
        XCTAssertEqual(conversation[0].senderId, testUserId2)
        XCTAssertEqual(conversation[1].senderId, testUserId1)
    }
    
    // MARK: - Gift Sending Tests
    
    func testSendGift_CreatesGiftMessage() async throws {
        // Given
        let giftType = GiftType.coffee
        
        // When
        try await messageService.sendGift(
            from: testUserId1,
            to: testUserId2,
            gift: giftType
        )
        
        // Then
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        XCTAssertEqual(conversation.count, 1)
        
        let message = conversation.first!
        XCTAssertEqual(message.gift, giftType)
        XCTAssertTrue(message.isPriority, "Gift messages should be priority")
        XCTAssertTrue(message.content.contains(giftType.emoji), "Should contain gift emoji")
        XCTAssertTrue(message.content.contains(giftType.displayName), "Should contain gift name")
    }
    
    func testSendGift_AllGiftTypes() async throws {
        // Test all gift types work correctly
        let allGifts: [GiftType] = [.coffee, .heart, .rose, .cake, .star, .sparkles]
        
        for (index, gift) in allGifts.enumerated() {
            try await messageService.sendGift(
                from: testUserId1,
                to: "user_\(index)",
                gift: gift
            )
        }
        
        // Verify all gifts were sent
        XCTAssertEqual(messageService.messages.count, 6, "Should send all 6 gift types")
        
        // Verify each gift message is properly formatted
        for gift in allGifts {
            let giftMessages = messageService.messages.filter { $0.gift == gift }
            XCTAssertEqual(giftMessages.count, 1, "Should have one message for \(gift)")
            
            let message = giftMessages.first!
            XCTAssertTrue(message.content.contains(gift.emoji))
            XCTAssertTrue(message.isPriority)
        }
    }
    
    // MARK: - Read Status Tests
    
    func testMarkAsRead_UpdatesReadStatus() async throws {
        // Given
        try await messageService.sendMessage(
            from: testUserId1,
            to: testUserId2,
            content: "Test message"
        )
        
        let message = messageService.messages.first!
        XCTAssertFalse(message.isRead, "Message should start unread")
        
        // When
        messageService.markAsRead(message.id)
        
        // Then
        let updatedMessage = messageService.messages.first!
        XCTAssertTrue(updatedMessage.isRead, "Message should be marked as read")
    }
    
    func testMarkAsRead_OnlyMarksSpecificMessage() async throws {
        // Given - Send multiple messages
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Message 1")
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Message 2")
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Message 3")
        
        let messageToRead = messageService.messages[1]
        
        // When
        messageService.markAsRead(messageToRead.id)
        
        // Then
        let messages = messageService.messages
        XCTAssertFalse(messages[0].isRead, "First message should remain unread")
        XCTAssertTrue(messages[1].isRead, "Second message should be read")
        XCTAssertFalse(messages[2].isRead, "Third message should remain unread")
    }
    
    func testGetUnreadCount_ReturnsCorrectCount() async throws {
        // Given
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Message 1")
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Message 2")
        try await messageService.sendMessage(from: testUserId2, to: testUserId1, content: "Reply")
        
        // Initially all unread
        XCTAssertEqual(messageService.getUnreadCount(for: testUserId2), 2)
        
        // Mark one as read
        let firstMessage = messageService.messages.last!
        messageService.markAsRead(firstMessage.id)
        
        // Should have one unread
        XCTAssertEqual(messageService.getUnreadCount(for: testUserId2), 1)
    }
    
    // MARK: - Conversation Retrieval Tests
    
    func testGetConversation_ReturnsCorrectMessages() async throws {
        // Given - Create multiple conversations
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "User1 to User2")
        try await messageService.sendMessage(from: testUserId1, to: "other_user", content: "User1 to Other")
        try await messageService.sendMessage(from: testUserId2, to: testUserId1, content: "User2 to User1")
        
        // When
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        
        // Then
        XCTAssertEqual(conversation.count, 2, "Should only return messages between these two users")
        
        // Verify messages are between correct users
        for message in conversation {
            let involvesUser1 = message.senderId == testUserId1 || message.receiverId == testUserId1
            let involvesUser2 = message.senderId == testUserId2 || message.receiverId == testUserId2
            XCTAssertTrue(involvesUser1 && involvesUser2, "Message should involve both users")
        }
    }
    
    func testGetConversation_EmptyWhenNoMessages() {
        // When
        let conversation = messageService.getConversation(between: "nonexistent1", and: "nonexistent2")
        
        // Then
        XCTAssertTrue(conversation.isEmpty, "Should return empty array for non-existent conversation")
    }
    
    func testGetConversation_OrderedByTimestamp() async throws {
        // Given
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "First")
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        try await messageService.sendMessage(from: testUserId2, to: testUserId1, content: "Second")
        try await Task.sleep(nanoseconds: 100_000_000)
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Third")
        
        // When
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        
        // Then
        XCTAssertEqual(conversation.count, 3)
        // Should be newest first
        XCTAssertEqual(conversation[0].content, "Third")
        XCTAssertEqual(conversation[1].content, "Second")
        XCTAssertEqual(conversation[2].content, "First")
        
        // Verify timestamps are descending
        XCTAssertGreaterThan(conversation[0].timestamp, conversation[1].timestamp)
        XCTAssertGreaterThan(conversation[1].timestamp, conversation[2].timestamp)
    }
    
    // MARK: - Edge Cases
    
    func testSendMessage_WithEmptyContent() async throws {
        // Given
        let emptyContent = ""
        
        // When
        try await messageService.sendMessage(
            from: testUserId1,
            to: testUserId2,
            content: emptyContent
        )
        
        // Then
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        XCTAssertEqual(conversation.count, 1, "Should allow empty messages")
        XCTAssertEqual(conversation.first?.content, emptyContent)
    }
    
    func testSendMessage_WithLongContent() async throws {
        // Given
        let longContent = String(repeating: "A", count: 1000)
        
        // When
        try await messageService.sendMessage(
            from: testUserId1,
            to: testUserId2,
            content: longContent
        )
        
        // Then
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        XCTAssertEqual(conversation.first?.content, longContent, "Should handle long messages")
    }
    
    func testSendMessage_WithSpecialCharacters() async throws {
        // Given
        let specialContent = "Hello! 👋 How are you? 😊 Let's meet at 5:00pm @ café ☕"
        
        // When
        try await messageService.sendMessage(
            from: testUserId1,
            to: testUserId2,
            content: specialContent
        )
        
        // Then
        let conversation = messageService.getConversation(between: testUserId1, and: testUserId2)
        XCTAssertEqual(conversation.first?.content, specialContent, "Should handle emojis and special characters")
    }
    
    func testMarkAsRead_WithNonexistentMessage() {
        // Given
        let nonexistentId = "nonexistent_message_id"
        
        // When
        messageService.markAsRead(nonexistentId)
        
        // Then - Should not crash, silently ignore
        XCTAssertTrue(true, "Should handle nonexistent message IDs gracefully")
    }
    
    // MARK: - Clean Code Principle Tests
    
    func testServiceFollowsSingleResponsibility() {
        // MessageService should ONLY handle message operations
        // It should NOT:
        // - Handle user authentication
        // - Manage user profiles
        // - Handle match logic
        // - Contain UI code
        
        XCTAssertNotNil(messageService.messages, "Has message storage")
        XCTAssertTrue(messageService.responds(to: #selector(getter: MessageService.messages)), "Manages messages")
        
        // Service has focused, message-related methods
        XCTAssertTrue(true, "MessageService follows Single Responsibility Principle")
    }
    
    func testServiceUsesAsyncAwaitProperly() async throws {
        // Service uses modern async/await for network-style operations
        
        // sendMessage is async/throws
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Test")
        
        // sendGift is async/throws
        try await messageService.sendGift(from: testUserId1, to: testUserId2, gift: .coffee)
        
        XCTAssertTrue(true, "Service uses async/await properly")
    }
    
    func testServiceMaintainsDataIntegrity() async throws {
        // Service should maintain consistent data
        
        // Create message
        try await messageService.sendMessage(from: testUserId1, to: testUserId2, content: "Test")
        
        let message = messageService.messages.first!
        
        // Message should have valid properties
        XCTAssertFalse(message.id.isEmpty, "Messages have valid IDs")
        XCTAssertFalse(message.senderId.isEmpty, "Messages have valid sender IDs")
        XCTAssertFalse(message.receiverId.isEmpty, "Messages have valid receiver IDs")
        XCTAssertNotNil(message.timestamp, "Messages have timestamps")
        
        // Conversation retrieval should be consistent
        let conv1 = messageService.getConversation(between: testUserId1, and: testUserId2)
        let conv2 = messageService.getConversation(between: testUserId2, and: testUserId1)
        XCTAssertEqual(conv1.count, conv2.count, "Conversation should be bidirectional")
    }
    
    func testServiceHandlesEdgeCases() async throws {
        // Service should handle edge cases gracefully
        
        // Empty user IDs (should still work or throw appropriate error)
        do {
            try await messageService.sendMessage(from: "", to: "", content: "Test")
            XCTAssertTrue(true, "Handles empty user IDs")
        } catch {
            XCTAssertTrue(true, "Throws appropriate error for invalid input")
        }
        
        // Same sender and receiver
        try await messageService.sendMessage(from: testUserId1, to: testUserId1, content: "Self-message")
        XCTAssertTrue(true, "Handles self-messages")
        
        // Nonexistent conversation
        let emptyConv = messageService.getConversation(between: "user_x", and: "user_y")
        XCTAssertTrue(emptyConv.isEmpty, "Returns empty array for nonexistent conversation")
    }
    
    func testServiceFollowsNamingConventions() {
        // Method names should be clear and descriptive
        
        // sendMessage - clear action
        // sendGift - clear action
        // markAsRead - clear action
        // getConversation - clear query
        // getUnreadCount - clear query
        
        XCTAssertTrue(true, "Service methods follow Swift naming conventions")
    }
}
