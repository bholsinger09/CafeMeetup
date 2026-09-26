import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeDiscovery

/// Study buddy recommendation filters
public struct RecommendationFilters {
    public var sameCollegeOnly = false
    public var maxDistance: Double? = 5.0
    public var sameMajorOnly = false
    public var requireSharedCourses = false
    public var onlyRecentlyActive = false
    public var minCompatibilityScore: Double = 0.5
}

/// ViewModel for study buddy recommendation and matching
@MainActor
public class StudyBuddyRecommendationViewModel: ObservableObject {
    @Published public var recommendations: [StudyBuddyRecommendation] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var currentUser: User?
    @Published public var todayMatches: [StudyBuddyRecommendation] = []
    @Published public var error: String?
    @Published public var filters = RecommendationFilters()
    @Published public var totalLikes: Int = 0
    @Published public var totalPasses: Int = 0
    
    public init() {
        Task {
            await loadRecommendations()
        }
    }
    
    public func loadRecommendations() async {
        isLoading = true
        // Mock data - in production would load from service
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    public func likeRecommendation(_ recommendation: StudyBuddyRecommendation) {
        print("Liked: \(recommendation.user.fullName)")
        totalLikes += 1
    }
    
    public func passOnRecommendation(_ recommendation: StudyBuddyRecommendation) {
        print("Passed on: \(recommendation.user.fullName)")
        totalPasses += 1
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
    
    public func passCurrentRecommendation() {
        if !recommendations.isEmpty {
            let current = recommendations.first!
            passOnRecommendation(current)
        }
    }
    
    public func likeCurrentRecommendation() {
        if !recommendations.isEmpty {
            let current = recommendations.first!
            likeRecommendation(current)
        }
    }
    
    public func refresh() async {
        await loadRecommendations()
    }
    
    public func applyFilters() async {
        isLoading = true
        // In production, this would filter recommendations based on filters
        try? await Task.sleep(nanoseconds: 300_000_000)
        isLoading = false
    }
    
    public func resetFilters() {
        filters = RecommendationFilters()
    }
}

