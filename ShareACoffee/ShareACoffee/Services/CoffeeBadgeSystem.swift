import Foundation
import ShareACoffeeCore

/// System for managing coffee-related badges and rewards
public final class CoffeeBadgeSystem: Sendable {
    public nonisolated(unsafe) static let shared = CoffeeBadgeSystem()
    
    private init() {}
    
    /// Badge types
    public enum BadgeType {
        case coffeeLover
        case meetupHost
        case studyBuddy
        case explorer
    }
    
    /// All available badges
    public nonisolated(unsafe) static let allBadges: [BadgeType] = [.coffeeLover, .meetupHost, .studyBuddy, .explorer]
    
    /// Get badge details
    public func getBadgeDetails(for type: BadgeType) -> (name: String, description: String, icon: String) {
        switch type {
        case .coffeeLover:
            return ("Coffee Lover", "Visited 5 different coffee shops", "☕")
        case .meetupHost:
            return ("Meetup Host", "Hosted a coffee meetup", "🎉")
        case .studyBuddy:
            return ("Study Buddy", "Found a study partner", "📚")
        case .explorer:
            return ("Explorer", "Visited 10 different locations", "🗺️")
        }
    }
    
    /// Check if user earned badge
    public func checkBadge(for user: User, type: BadgeType) -> Bool {
        // Implementation would check actual user achievements
        return false
    }
}
