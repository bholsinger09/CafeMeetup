import Foundation

protocol MessageServiceProtocol {
    func sendMessage(senderId: String, receiverId: String, content: String, isPriority: Bool) async throws -> Message
    func sendGift(senderId: String, receiverId: String, giftType: GiftType, message: String?) async throws -> Message
    func getConversation(userId1: String, userId2: String) async throws -> [Message]
    func markAsRead(messageId: String) async throws
    func getUnreadCount(forUserId userId: String) async throws -> Int
}

@MainActor
class MessageService: MessageServiceProtocol {
    static let shared = MessageService()
    
    private init() {}
    
    private var messages: [Message] = []
    
    func sendMessage(senderId: String, receiverId: String, content: String, isPriority: Bool = false) async throws -> Message {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let message = Message(
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            isPriority: isPriority
        )
        
        messages.append(message)
        print("[MessageService] Message sent from \(senderId) to \(receiverId)\(isPriority ? " [PRIORITY]" : "")")
        
        return message
    }
    
    func sendGift(senderId: String, receiverId: String, giftType: GiftType, message: String? = nil) async throws -> Message {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let giftMessage = Message(
            senderId: senderId,
            receiverId: receiverId,
            content: message ?? "Sent you a \(giftType.displayName)",
            giftType: giftType
        )
        
        messages.append(giftMessage)
        print("[MessageService] Gift sent: \(giftType.emoji) from \(senderId) to \(receiverId)")
        
        return giftMessage
    }
    
    func getConversation(userId1: String, userId2: String) async throws -> [Message] {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let conversation = messages.filter {
            ($0.senderId == userId1 && $0.receiverId == userId2) ||
            ($0.senderId == userId2 && $0.receiverId == userId1)
        }.sorted(by: { $0.sentAt < $1.sentAt })
        
        print("[MessageService] Loaded \(conversation.count) messages between \(userId1) and \(userId2)")
        return conversation
    }
    
    func markAsRead(messageId: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].readAt = Date()
            print("[MessageService] Message \(messageId) marked as read")
        }
    }
    
    func getUnreadCount(forUserId userId: String) async throws -> Int {
        let unread = messages.filter { $0.receiverId == userId && $0.readAt == nil }
        return unread.count
    }
    
    // Helper to get last message in a conversation
    func getLastMessage(userId1: String, userId2: String) async -> Message? {
        let conversation = messages.filter {
            ($0.senderId == userId1 && $0.receiverId == userId2) ||
            ($0.senderId == userId2 && $0.receiverId == userId1)
        }.sorted(by: { $0.sentAt > $1.sentAt })
        
        return conversation.first
    }
}
