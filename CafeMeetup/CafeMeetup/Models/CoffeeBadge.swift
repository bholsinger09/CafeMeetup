import Foundation

/// Coffee Badge System - Unique gamification for coffee enthusiasts
/// Users earn badges for coffee-related activities and dating milestones
struct CoffeeBadge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let rarity: BadgeRarity
    let unlockCriteria: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    enum BadgeRarity: String, Codable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
    }
    
    init(id: String, name: String, description: String, emoji: String, rarity: BadgeRarity, unlockCriteria: String) {
        self.id = id
        self.name = name
        self.description = description
        self.emoji = emoji
        self.rarity = rarity
        self.unlockCriteria = unlockCriteria
        self.isUnlocked = false
        self.unlockedDate = nil
    }
}

/// All available coffee badges in the app
class CoffeeBadgeSystem {
    static let allBadges: [CoffeeBadge] = [
        // Coffee Knowledge Badges
        CoffeeBadge(
            id: "first_latte",
            name: "First Latte",
            description: "Complete your first coffee date",
            emoji: "☕️",
            rarity: .common,
            unlockCriteria: "Complete 1 café check-in"
        ),
        CoffeeBadge(
            id: "barista_basics",
            name: "Barista Basics",
            description: "Visit 5 different coffee shops",
            emoji: "👨‍🍳",
            rarity: .common,
            unlockCriteria: "Check in at 5 unique cafés"
        ),
        CoffeeBadge(
            id: "coffee_connoisseur",
            name: "Coffee Connoisseur",
            description: "Visit 15 different coffee shops",
            emoji: "🎓",
            rarity: .rare,
            unlockCriteria: "Check in at 15 unique cafés"
        ),
        CoffeeBadge(
            id: "espresso_expert",
            name: "Espresso Expert",
            description: "Try all coffee types with matches",
            emoji: "⭐️",
            rarity: .epic,
            unlockCriteria: "Have conversations about all 10 coffee types"
        ),
        
        // Social Badges
        CoffeeBadge(
            id: "social_butterfly",
            name: "Social Butterfly",
            description: "Match with 10 people",
            emoji: "🦋",
            rarity: .common,
            unlockCriteria: "Get 10 mutual matches"
        ),
        CoffeeBadge(
            id: "conversation_starter",
            name: "Conversation Starter",
            description: "Send 50 messages",
            emoji: "💬",
            rarity: .common,
            unlockCriteria: "Send 50 total messages"
        ),
        CoffeeBadge(
            id: "heartfelt_connector",
            name: "Heartfelt Connector",
            description: "Receive 5 virtual gifts",
            emoji: "💝",
            rarity: .rare,
            unlockCriteria: "Receive 5 gifts from matches"
        ),
        
        // Date Badges
        CoffeeBadge(
            id: "morning_person",
            name: "Morning Person",
            description: "Check in to a café before 8 AM",
            emoji: "🌅",
            rarity: .rare,
            unlockCriteria: "Check in before 8:00 AM"
        ),
        CoffeeBadge(
            id: "study_buddy",
            name: "Study Buddy",
            description: "Complete 3 study sessions with matches",
            emoji: "📚",
            rarity: .rare,
            unlockCriteria: "Join 3 study session meetups"
        ),
        CoffeeBadge(
            id: "coffee_date_pro",
            name: "Coffee Date Pro",
            description: "Go on 10 coffee dates",
            emoji: "🏆",
            rarity: .epic,
            unlockCriteria: "Check in with match 10 times"
        ),
        
        // Special Event Badges
        CoffeeBadge(
            id: "latte_legend",
            name: "Latte Legend",
            description: "Be active for 30 consecutive days",
            emoji: "👑",
            rarity: .legendary,
            unlockCriteria: "30-day streak of app usage"
        ),
        CoffeeBadge(
            id: "campus_connector",
            name: "Campus Connector",
            description: "Match with people from 3 different majors",
            emoji: "🎯",
            rarity: .epic,
            unlockCriteria: "Match with 3 different academic backgrounds"
        ),
        CoffeeBadge(
            id: "ice_breaker_master",
            name: "Ice Breaker Master",
            description: "Use 20 icebreaker questions",
            emoji: "❄️",
            rarity: .rare,
            unlockCriteria: "Send 20 icebreaker messages"
        ),
        
        // Hidden/Secret Badges
        CoffeeBadge(
            id: "early_adopter",
            name: "Early Adopter",
            description: "One of the first 1000 users",
            emoji: "🌟",
            rarity: .legendary,
            unlockCriteria: "Join in first month of launch"
        ),
        CoffeeBadge(
            id: "perfect_match",
            name: "Perfect Match",
            description: "Match with someone who shares all your coffee preferences",
            emoji: "💞",
            rarity: .legendary,
            unlockCriteria: "100% coffee preference match"
        )
    ]
}
