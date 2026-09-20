import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeSocial

/// ViewModel for messages and chat
@MainActor
public class MessageViewModel: ObservableObject {
    @Published public var messages: [Message] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    private let messageService = MessageService.shared
    
    public init() {}
    
    public func loadMessages() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
    
    /// Load a conversation between two users
    public func loadConversation(userId1: String, userId2: String) async {
        isLoading = true
        defer { isLoading = false }
        
        // Load messages from service
        do {
            // Fetch conversation messages
            let conversationMessages = try await messageService.getConversation(
                userId1: userId1,
                userId2: userId2
            )
            messages = conversationMessages
        } catch {
            errorMessage = "Failed to load conversation: \(error.localizedDescription)"
        }
    }
    
    /// Send a message
    public func sendMessage(
        senderId: String,
        receiverId: String,
        content: String,
        isPriority: Bool = false
    ) async {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Message cannot be empty"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Send via service
            let message = try await messageService.sendMessage(
                senderId: senderId,
                receiverId: receiverId,
                content: content,
                isPriority: isPriority
            )
            
            // Add to local messages
            messages.append(message)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }
    
    /// Send a virtual gift
    public func sendGift(
        senderId: String,
        receiverId: String,
        giftType: GiftType
    ) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Send gift via service
            let message = try await messageService.sendGift(
                senderId: senderId,
                receiverId: receiverId,
                giftType: giftType
            )
            
            // Add to local messages
            messages.append(message)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to send gift: \(error.localizedDescription)"
        }
    }
}
