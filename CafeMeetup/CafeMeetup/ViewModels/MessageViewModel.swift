import Foundation
import Combine

@MainActor
class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let messageService: MessageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(messageService: MessageServiceProtocol = MessageService.shared) {
        self.messageService = messageService
    }
    
    func loadConversation(userId1: String, userId2: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            messages = try await messageService.getConversation(userId1: userId1, userId2: userId2)
            
            // Mark messages as read
            for message in messages where message.receiverId == userId1 && !message.isRead {
                try? await messageService.markAsRead(messageId: message.id)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("[MessageViewModel] Error loading conversation: \(error)")
        }
        
        isLoading = false
    }
    
    func sendMessage(senderId: String, receiverId: String, content: String, isPriority: Bool = false) async {
        do {
            let message = try await messageService.sendMessage(
                senderId: senderId,
                receiverId: receiverId,
                content: content,
                isPriority: isPriority
            )
            messages.append(message)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func sendGift(senderId: String, receiverId: String, giftType: GiftType, message: String? = nil) async {
        do {
            let giftMessage = try await messageService.sendGift(
                senderId: senderId,
                receiverId: receiverId,
                giftType: giftType,
                message: message
            )
            messages.append(giftMessage)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
