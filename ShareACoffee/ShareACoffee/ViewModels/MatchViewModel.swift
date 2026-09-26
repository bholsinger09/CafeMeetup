import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeSocial

/// Match model
public struct Match: Identifiable, Codable {
    public let id: String
    public let userId: String
    public let otherUserId: String
    public let matchedAt: Date
    public var unreadCount: Int = 0
    
    public init(id: String, userId: String, otherUserId: String, matchedAt: Date, unreadCount: Int = 0) {
        self.id = id
        self.userId = userId
        self.otherUserId = otherUserId
        self.matchedAt = matchedAt
        self.unreadCount = unreadCount
    }
    
    /// Get the ID of the other user in this match
    public func otherUserId(currentUserId: String) -> String {
        return userId == currentUserId ? otherUserId : userId
    }
}

/// ViewModel for user matching and connections
@MainActor
public class MatchViewModel: ObservableObject {
    @Published public var matches: [Match] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    public init() {
        loadMatches()
    }
    
    public func loadMatches() {
        isLoading = true
        // Mock data - in production would load from service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
    
    public func fetchMatches(forUserId userId: String) async {
        isLoading = true
        // Mock fetch - in production would load from service
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    public func getMatchedUser(match: Match, currentUserId: String) async -> User? {
        // In production, would fetch the actual matched user
        return nil
    }
}
