import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeDiscovery

/// ViewModel for study buddy recommendation and matching
@MainActor
public class StudyBuddyRecommendationViewModel: ObservableObject {
    @Published public var recommendations: [StudyBuddyRecommendation] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var currentUser: User?
    @Published public var todayMatches: [StudyBuddyRecommendation] = []
    @Published public var error: String?
    
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
    
    public func likeRecommendation(_ recommendation: StudyBuddyRecommendation) {
        print("Liked: \(recommendation.user.fullName)")
    }
    
    public func passOnRecommendation(_ recommendation: StudyBuddyRecommendation) {
        print("Passed on: \(recommendation.user.fullName)")
    }
    
    public func handleSwipe(_ action: SwipeAction, for recommendation: StudyBuddyRecommendation) {
        switch action {
        case .like:
            likeRecommendation(recommendation)
        case .pass:
            passOnRecommendation(recommendation)
        case .superLike:
            print("Super liked: \(recommendation.user.fullName)")
        }
    }
    
    public func refresh() {
        loadRecommendations()
    }
}

