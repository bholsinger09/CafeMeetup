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
    
    public init() {
        loadMessages()
    }
    
    public func loadMessages() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
}
