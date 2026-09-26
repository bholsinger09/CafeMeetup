import Foundation
import Combine
import ShareACoffeeCore

/// Manages achievement tracking and unlocking
public final class AchievementManager: NSObject, ObservableObject {
    @Published public var achievements: [Achievement] = []
    @Published public var unlockedAchievements: [Achievement] = []
    @Published public var completionPercentage: Double = 0.0
    @Published public var recentlyUnlocked: Achievement?
    
    public var unlockedCount: Int {
        unlockedAchievements.count
    }
    
    public var totalCount: Int {
        achievements.count
    }
    
    public nonisolated(unsafe) static let shared = AchievementManager()
    
    override private init() {
        super.init()
        loadAchievements()
    }
    
    private func loadAchievements() {
        // Initialize with sample achievements
        achievements = [
            Achievement(id: "first_study", title: "First Study Session", description: "Start your first study session", icon: "book.fill", category: .academic, rarity: .common, isUnlocked: true, progress: 1, requirement: 1),
            Achievement(id: "five_sessions", title: "Dedicated Student", description: "Complete 5 study sessions", icon: "book.circle.fill", category: .academic, rarity: .rare, isUnlocked: false, progress: 2, requirement: 5),
            Achievement(id: "coffee_lover", title: "Coffee Lover", description: "Visit 5 different coffee shops", icon: "cup.and.saucer.fill", category: .coffee, rarity: .rare, isUnlocked: false, progress: 3, requirement: 5),
            Achievement(id: "social_butterfly", title: "Social Butterfly", description: "Make 10 study buddies", icon: "person.2.fill", category: .social, rarity: .epic, isUnlocked: false, progress: 4, requirement: 10),
            Achievement(id: "explorer", title: "Explorer", description: "Discover 20 study locations", icon: "map.fill", category: .explorer, rarity: .legendary, isUnlocked: false, progress: 8, requirement: 20),
        ]
        
        unlockedAchievements = achievements.filter { $0.isUnlocked }
        updateCompletionPercentage()
    }
    
    private func updateCompletionPercentage() {
        let unlocked = Double(unlockedAchievements.count)
        let total = Double(achievements.count)
        completionPercentage = total > 0 ? unlocked / total : 0.0
    }
    
    public func checkAndUnlockAchievements(for user: User) {
        // Check conditions and unlock achievements
    }
}
