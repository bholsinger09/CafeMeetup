import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeDiscovery

/// ViewModel for study buddy discovery
@MainActor
public class DiscoveryViewModel: ObservableObject {
    @Published public var recommendations: [StudyBuddyRecommendation] = []
    @Published public var potentialMatches: [User] = []
    @Published public var currentUserIndex: Int = 0
    @Published public var matchedUser: User?
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var currentUser: User?
    @Published public var showMatchPopup = false
    @Published public var selectedRecommendation: StudyBuddyRecommendation?
    
    public init() {
        loadRecommendations()
    }
    
    public func loadRecommendations() {
        isLoading = true
        // Mock data - in production would load from service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
    
    public func loadPotentialMatches(currentUserId: String, currentUserCity: String, currentUserState: String) async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    public func likeUser(currentUserId: String, likedUser: User) async {
        // Like a user - match logic here
        print("💖 Liked user: \(likedUser.fullName)")
    }
    
    public func passUser() {
        // Move to next user
        if currentUserIndex < potentialMatches.count - 1 {
            currentUserIndex += 1
        }
    }
    
    public func resetState() {
        currentUserIndex = 0
        potentialMatches = []
        matchedUser = nil
    }
}
