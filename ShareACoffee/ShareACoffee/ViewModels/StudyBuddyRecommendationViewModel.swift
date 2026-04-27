import Foundation
import SwiftUI
import Combine

/// View model for managing study buddy recommendations
@MainActor
class StudyBuddyRecommendationViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var recommendations: [StudyBuddyRecommendation] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var filters = RecommendationFilters.default
    @Published var showFilters = false
    
    // Statistics
    @Published var totalLikes = 0
    @Published var totalPasses = 0
    @Published var todayMatches = 0
    
    // MARK: - Dependencies
    
    private let recommendationService = StudyBuddyRecommendationService.shared
    private let userService = UserService.shared
    private let matchService = MatchService.shared
    
    // MARK: - Current User
    
    var currentUser: User?
    
    // MARK: - Initialization
    
    func loadRecommendations(for user: User) async {
        currentUser = user
        isLoading = true
        error = nil
        
        do {
            // Fetch all potential candidates
            let allUsers = userService.getAllUsers()
            
            // Filter out users already liked/matched
            let likedUserIds = try await getLikedUserIds(for: user.id)
            let matchedUserIds = try await getMatchedUserIds(for: user.id)
            let excludedIds = Set(likedUserIds + matchedUserIds + [user.id])
            
            let candidates = allUsers.filter { !excludedIds.contains($0.id) }
            
            // Generate recommendations using ML service
            let newRecommendations = await recommendationService.generateRecommendations(
                for: user,
                from: candidates,
                filters: filters,
                limit: 50
            )
            
            recommendations = newRecommendations
            isLoading = false
            
            print("✅ Loaded \(recommendations.count) recommendations")
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            print("❌ Error loading recommendations: \(error)")
        }
    }
    
    // MARK: - Swipe Actions
    
    func handleSwipe(recommendation: StudyBuddyRecommendation, action: SwipeAction) {
        guard let currentUser = currentUser else { return }
        
        Task {
            switch action {
            case .like:
                await handleLike(recommendation: recommendation)
            case .pass:
                await handlePass(recommendation: recommendation)
            case .superLike:
                await handleSuperLike(recommendation: recommendation)
            }
            
            // Remove from recommendations
            withAnimation {
                recommendations.removeAll { $0.id == recommendation.id }
            }
        }
    }
    
    private func handleLike(recommendation: StudyBuddyRecommendation) async {
        guard let currentUser = currentUser else { return }
        
        do {
            totalLikes += 1
            
            let isMatch = try await matchService.addLike(
                userId: currentUser.id,
                likedUserId: recommendation.user.id
            )
            
            if isMatch {
                // Show match celebration
                withAnimation {
                    todayMatches += 1
                }
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                print("🎉 It's a match with \(recommendation.user.fullName)!")
            } else {
                print("💚 Liked \(recommendation.user.fullName)")
            }
        } catch {
            print("❌ Error liking user: \(error)")
        }
    }
    
    private func handlePass(recommendation: StudyBuddyRecommendation) async {
        totalPasses += 1
        print("👎 Passed on \(recommendation.user.fullName)")
    }
    
    private func handleSuperLike(recommendation: StudyBuddyRecommendation) async {
        // Future feature: Super like with special notification
        print("⭐️ Super liked \(recommendation.user.fullName)")
    }
    
    // MARK: - Data Fetching
    
    private func getLikedUserIds(for userId: String) async throws -> [String] {
        // Get all likes by current user
        let allLikes = matchService.getAllLikes()
        return allLikes.filter { $0.userId == userId }.map { $0.likedUserId }
    }
    
    private func getMatchedUserIds(for userId: String) async throws -> [String] {
        let matches = try await matchService.getMatches(forUserId: userId)
        return matches.map { $0.otherUserId(currentUserId: userId) }
    }
    
    // MARK: - Filter Management
    
    func applyFilters() async {
        guard let currentUser = currentUser else { return }
        await loadRecommendations(for: currentUser)
    }
    
    func resetFilters() {
        filters = .default
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        guard let currentUser = currentUser else { return }
        await loadRecommendations(for: currentUser)
    }
    
    // MARK: - Manual Actions (for button controls)
    
    func likeCurrentRecommendation() {
        guard let first = recommendations.first else { return }
        handleSwipe(recommendation: first, action: .like)
    }
    
    func passCurrentRecommendation() {
        guard let first = recommendations.first else { return }
        handleSwipe(recommendation: first, action: .pass)
    }
}
