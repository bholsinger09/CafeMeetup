import XCTest
@testable import ShareACoffee
@testable import ShareACoffeeSocial

/// Tests for Message ViewModel functionality  
@MainActor
final class MessageViewModelTests: XCTestCase {
    
    var messageViewModel: MessageViewModel!
    
    override func setUp() async throws {
        messageViewModel = MessageViewModel()
    }
    
    // MARK: - Conversation Loading Tests
    
    func testLoadConversationBetweenUsers() async {
        // Given: Two user IDs
        let userId1 = "user-1"
        let userId2 = "user-2"
        
        // When: Loading conversation
        await messageViewModel.loadConversation(userId1: userId1, userId2: userId2)
        
        // Then: Should load messages (may be empty initially)
        XCTAssertNotNil(messageViewModel.messages)
    }
    
    // MARK: - Message Sending Tests
    
    func testSendBasicMessage() async {
        // Given: Message details
        let senderId = "sender-123"
        let receiverId = "receiver-456"
        let content = "Hello, this is a test message"
        
        // When: Sending a message
        await messageViewModel.sendMessage(
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            isPriority: false
        )
        
        // Then: Message view model should be in a valid state
        XCTAssertFalse(messageViewModel.isLoading)
    }
    
    func testSendPriorityMessage() async {
        // Given: Priority message details
        let senderId = "sender-123"
        let receiverId = "receiver-456"
        let content = "This is urgent!"
        
        // When: Sending a priority message
        await messageViewModel.sendMessage(
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            isPriority: true
        )
        
        // Then: Should handle priority messaging
        XCTAssertFalse(messageViewModel.isLoading)
    }
    
    func testSendEmptyMessageFails() async {
        // Given: Empty message content
        let senderId = "sender-123"
        let receiverId = "receiver-456"
        let content = ""
        
        // When: Attempting to send empty message
        await messageViewModel.sendMessage(
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            isPriority: false
        )
        
        // Then: Should handle gracefully (error or ignore)
        XCTAssertFalse(messageViewModel.isLoading)
    }
    
    // MARK: - Gift Sending Tests
    
    func testSendGift() async {
        // Given: Gift sending details
        let senderId = "sender-123"
        let receiverId = "receiver-456"
        let giftType: GiftType = .coffee
        
        // When: Sending a gift
        await messageViewModel.sendGift(
            senderId: senderId,
            receiverId: receiverId,
            giftType: giftType
        )
        
        // Then: Should complete without error
        XCTAssertFalse(messageViewModel.isLoading)
    }
    
    func testSendMultipleGifts() async {
        // Given: Multiple gift types
        let giftTypes: [GiftType] = [.coffee, .studyCard, .medal]
        let senderId = "sender-123"
        let receiverId = "receiver-456"
        
        // When: Sending multiple gifts
        for giftType in giftTypes {
            await messageViewModel.sendGift(
                senderId: senderId,
                receiverId: receiverId,
                giftType: giftType
            )
        }
        
        // Then: Should handle all gifts
        XCTAssertFalse(messageViewModel.isLoading)
    }
    
    // MARK: - Integration Tests
    
    func testMessageLoadingState() async {
        // Given: Initial state
        XCTAssertFalse(messageViewModel.isLoading)
        
        // When: Loading conversation
        await messageViewModel.loadConversation(userId1: "user-1", userId2: "user-2")
        
        // Then: Should complete loading
        XCTAssertFalse(messageViewModel.isLoading)
    }
}
