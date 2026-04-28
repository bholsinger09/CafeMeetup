import Foundation
import SwiftUI

/// Study achievement badges and milestones
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    let rarity: AchievementRarity
    var unlockedAt: Date?
    var progress: Int
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
    
    var progressPercentage: Double {
        min(Double(progress) / Double(requirement), 1.0)
    }
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        requirement: Int,
        rarity: AchievementRarity,
        unlockedAt: Date? = nil,
        progress: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.requirement = requirement
        self.rarity = rarity
        self.unlockedAt = unlockedAt
        self.progress = progress
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case study = "Study Hours"
    case streak = "Streaks"
    case social = "Social"
    case session = "Sessions"
    case collaboration = "Collaboration"
    case focus = "Focus"
    
    var icon: String {
        switch self {
        case .study:
            return "book.fill"
        case .streak:
            return "flame.fill"
        case .social:
            return "person.2.fill"
        case .session:
            return "checkmark.circle.fill"
        case .collaboration:
            return "person.3.fill"
        case .focus:
            return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .study:
            return .blue
        case .streak:
            return .orange
        case .social:
            return .purple
        case .session:
            return .green
        case .collaboration:
            return .pink
        case .focus:
            return .indigo
        }
    }
}

enum AchievementRarity: String, Codable, CaseIterable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .yellow
        }
    }
    
    var emoji: String {
        switch self {
        case .common:
            return "⚪"
        case .rare:
            return "🔵"
        case .epic:
            return "🟣"
        case .legendary:
            return "⭐"
        }
    }
}

// MARK: - Predefined Achievements

extension Achievement {
    static let allAchievements: [Achievement] = [
        // Study Hours
        Achievement(
            title: "First Steps",
            description: "Study for 1 hour",
            icon: "figure.walk",
            category: .study,
            requirement: 1,
            rarity: .common
        ),
        Achievement(
            title: "Dedicated Learner",
            description: "Study for 10 hours total",
            icon: "book.fill",
            category: .study,
            requirement: 10,
            rarity: .common
        ),
        Achievement(
            title: "Study Marathon",
            description: "Study for 50 hours total",
            icon: "bolt.fill",
            category: .study,
            requirement: 50,
            rarity: .rare
        ),
        Achievement(
            title: "Scholar",
            description: "Study for 100 hours total",
            icon: "graduationcap.fill",
            category: .study,
            requirement: 100,
            rarity: .epic
        ),
        Achievement(
            title: "Study Master",
            description: "Study for 500 hours total",
            icon: "crown.fill",
            category: .study,
            requirement: 500,
            rarity: .legendary
        ),
        
        // Streaks
        Achievement(
            title: "Consistency",
            description: "Maintain a 3-day study streak",
            icon: "flame.fill",
            category: .streak,
            requirement: 3,
            rarity: .common
        ),
        Achievement(
            title: "Week Warrior",
            description: "Maintain a 7-day study streak",
            icon: "flame.circle.fill",
            category: .streak,
            requirement: 7,
            rarity: .rare
        ),
        Achievement(
            title: "Unstoppable",
            description: "Maintain a 30-day study streak",
            icon: "flame.circle.fill",
            category: .streak,
            requirement: 30,
            rarity: .epic
        ),
        Achievement(
            title: "Legendary Streak",
            description: "Maintain a 100-day study streak",
            icon: "sparkles",
            category: .streak,
            requirement: 100,
            rarity: .legendary
        ),
        
        // Social
        Achievement(
            title: "First Match",
            description: "Match with your first study buddy",
            icon: "person.circle.fill",
            category: .social,
            requirement: 1,
            rarity: .common
        ),
        Achievement(
            title: "Social Butterfly",
            description: "Match with 10 study buddies",
            icon: "person.2.circle.fill",
            category: .social,
            requirement: 10,
            rarity: .rare
        ),
        Achievement(
            title: "Study Network",
            description: "Match with 50 study buddies",
            icon: "person.3.fill",
            category: .social,
            requirement: 50,
            rarity: .epic
        ),
        
        // Sessions
        Achievement(
            title: "Session Starter",
            description: "Complete 5 study sessions",
            icon: "checkmark.seal.fill",
            category: .session,
            requirement: 5,
            rarity: .common
        ),
        Achievement(
            title: "Regular Studier",
            description: "Complete 25 study sessions",
            icon: "checkmark.circle.fill",
            category: .session,
            requirement: 25,
            rarity: .rare
        ),
        Achievement(
            title: "Session Pro",
            description: "Complete 100 study sessions",
            icon: "star.circle.fill",
            category: .session,
            requirement: 100,
            rarity: .epic
        ),
        
        // Collaboration
        Achievement(
            title: "Team Player",
            description: "Join 5 collaborative sessions",
            icon: "person.2.wave.2.fill",
            category: .collaboration,
            requirement: 5,
            rarity: .common
        ),
        Achievement(
            title: "Collaboration King",
            description: "Join 25 collaborative sessions",
            icon: "person.3.sequence.fill",
            category: .collaboration,
            requirement: 25,
            rarity: .rare
        ),
        
        // Focus
        Achievement(
            title: "Deep Focus",
            description: "Complete a Pomodoro session",
            icon: "timer",
            category: .focus,
            requirement: 1,
            rarity: .common
        ),
        Achievement(
            title: "Focus Master",
            description: "Complete 50 Pomodoro sessions",
            icon: "brain.head.profile",
            category: .focus,
            requirement: 50,
            rarity: .epic
        ),
    ]
}
