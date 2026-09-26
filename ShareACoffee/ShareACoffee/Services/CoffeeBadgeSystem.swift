import Foundation
import ShareACoffeeCore

/// Badge rarity levels
public enum BadgeRarity: String, Codable, Sendable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
}

/// Badge model with unlock status
public struct CoffeeBadge: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String
    public let rarity: BadgeRarity
    public let unlockCriteria: String
    public var isUnlocked: Bool
    
    public init(id: String, name: String, description: String, icon: String, rarity: BadgeRarity = .common, unlockCriteria: String = "", isUnlocked: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.rarity = rarity
        self.unlockCriteria = unlockCriteria
        self.isUnlocked = isUnlocked
    }
}

/// System for managing coffee-related badges and rewards
public final class CoffeeBadgeSystem: Sendable {
    public nonisolated static let shared = CoffeeBadgeSystem()
    
    private init() {}
    
    /// Badge types
    public enum BadgeType: CaseIterable, Identifiable, Hashable, Sendable {
        case coffeeLover
        case meetupHost
        case studyBuddy
        case explorer
        
        public var id: String {
            switch self {
            case .coffeeLover:
                return "coffee_lover"
            case .meetupHost:
                return "meetup_host"
            case .studyBuddy:
                return "study_buddy"
            case .explorer:
                return "explorer"
            }
        }
    }
    
    /// All available badges
    public nonisolated static let allBadges: [CoffeeBadge] = [
        CoffeeBadge(id: "coffee_lover", name: "Coffee Lover", description: "Visited 5 different coffee shops", icon: "☕", rarity: .common, unlockCriteria: "Visit 5 coffee shops"),
        CoffeeBadge(id: "meetup_host", name: "Meetup Host", description: "Hosted a coffee meetup", icon: "🎉", rarity: .rare, unlockCriteria: "Host a meetup"),
        CoffeeBadge(id: "study_buddy", name: "Study Buddy", description: "Found a study partner", icon: "📚", rarity: .epic, unlockCriteria: "Find a study partner"),
        CoffeeBadge(id: "explorer", name: "Explorer", description: "Visited 10 different locations", icon: "🗺️", rarity: .legendary, unlockCriteria: "Visit 10 locations")
    ]
    
    /// Get badge by type
    public func getBadge(for type: BadgeType) -> CoffeeBadge {
        return Self.allBadges.first { $0.id == type.id } ?? Self.allBadges[0]
    }
    
    /// Check if user earned badge
    public func checkBadge(for user: User, type: BadgeType) -> Bool {
        // Implementation would check actual user achievements
        return false
    }
}
