import Foundation
import SwiftUI

/// Achievement rarity levels
public enum AchievementRarity: String, Codable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var emoji: String {
        switch self {
        case .common: return "⭐"
        case .rare: return "💫"
        case .epic: return "🌟"
        case .legendary: return "✨"
        }
    }
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

/// Achievement categories
public enum AchievementCategory: String, CaseIterable, Codable, Hashable {
    case social = "Social"
    case academic = "Academic"
    case coffee = "Coffee"
    case explorer = "Explorer"
    
    var icon: String {
        switch self {
        case .social: return "person.2.fill"
        case .academic: return "book.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .explorer: return "map.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .social: return .pink
        case .academic: return .blue
        case .coffee: return .orange
        case .explorer: return .green
        }
    }
}

/// Individual achievement
public struct Achievement: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let icon: String
    public let category: AchievementCategory
    public let rarity: AchievementRarity
    public var isUnlocked: Bool
    public var progress: Int
    public let requirement: Int
    
    public init(
        id: String,
        title: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        rarity: AchievementRarity,
        isUnlocked: Bool = false,
        progress: Int = 0,
        requirement: Int = 1
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.rarity = rarity
        self.isUnlocked = isUnlocked
        self.progress = progress
        self.requirement = requirement
    }
    
    public var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return Double(progress) / Double(requirement)
    }
}
