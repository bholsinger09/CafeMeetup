import SwiftUI

/// Custom theme system for personalized study aesthetics
enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case midnight = "Midnight"
    case ocean = "Ocean"
    case forest = "Forest"
    case sunset = "Sunset"
    case lavender = "Lavender"
    case autumn = "Autumn"
    case cherry = "Cherry Blossom"
    case arctic = "Arctic"
    case coffee = "Coffee House"
    case neon = "Neon"
    
    var id: String { rawValue }
    
    var isPremium: Bool {
        switch self {
        case .midnight, .ocean, .forest:
            return false
        case .sunset, .lavender, .autumn, .cherry, .arctic, .coffee, .neon:
            return true
        }
    }
    
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var gradientColors: [Color] {
        switch self {
        case .midnight:
            return [Color(hex: "1a1a2e"), Color(hex: "16213e")]
        case .ocean:
            return [Color(hex: "0f2027"), Color(hex: "203a43"), Color(hex: "2c5364")]
        case .forest:
            return [Color(hex: "134e4a"), Color(hex: "14532d")]
        case .sunset:
            return [Color(hex: "ff6b6b"), Color(hex: "ffa500"), Color(hex: "ffd700")]
        case .lavender:
            return [Color(hex: "a8c0ff"), Color(hex: "3f2b96")]
        case .autumn:
            return [Color(hex: "d4a373"), Color(hex: "8b4513")]
        case .cherry:
            return [Color(hex: "ffb7d5"), Color(hex: "c94b4b")]
        case .arctic:
            return [Color(hex: "e0f7fa"), Color(hex: "80deea"), Color(hex: "26c6da")]
        case .coffee:
            return [Color(hex: "6f4e37"), Color(hex: "3e2723")]
        case .neon:
            return [Color(hex: "ff006e"), Color(hex: "8338ec"), Color(hex: "3a86ff")]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .midnight:
            return Color(hex: "00d4ff")
        case .ocean:
            return Color(hex: "00b4d8")
        case .forest:
            return Color(hex: "10b981")
        case .sunset:
            return Color(hex: "ffd700")
        case .lavender:
            return Color(hex: "e0b1ff")
        case .autumn:
            return Color(hex: "ff8c42")
        case .cherry:
            return Color(hex: "ff69b4")
        case .arctic:
            return Color(hex: "00e5ff")
        case .coffee:
            return Color(hex: "d4a373")
        case .neon:
            return Color(hex: "00f5ff")
        }
    }
    
    var cardBackgroundColor: Color {
        switch self {
        case .midnight:
            return Color(hex: "0f3460")
        case .ocean:
            return Color(hex: "264653")
        case .forest:
            return Color(hex: "065f46")
        case .sunset:
            return Color.black.opacity(0.3)
        case .lavender:
            return Color(hex: "7209b7").opacity(0.3)
        case .autumn:
            return Color(hex: "582f0e").opacity(0.5)
        case .cherry:
            return Color(hex: "880e4f").opacity(0.4)
        case .arctic:
            return Color(hex: "006064").opacity(0.3)
        case .coffee:
            return Color(hex: "3e2723").opacity(0.7)
        case .neon:
            return Color.black.opacity(0.6)
        }
    }
    
    var textColor: Color {
        switch self {
        case .arctic:
            return Color(hex: "263238")
        default:
            return .white
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .arctic:
            return Color(hex: "546e7a")
        default:
            return .white.opacity(0.7)
        }
    }
    
    var icon: String {
        switch self {
        case .midnight:
            return "moon.stars.fill"
        case .ocean:
            return "water.waves"
        case .forest:
            return "leaf.fill"
        case .sunset:
            return "sun.max.fill"
        case .lavender:
            return "sparkles"
        case .autumn:
            return "leaf"
        case .cherry:
            return "camera.macro"
        case .arctic:
            return "snowflake"
        case .coffee:
            return "cup.and.saucer.fill"
        case .neon:
            return "bolt.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .midnight:
            return "🌙"
        case .ocean:
            return "🌊"
        case .forest:
            return "🌲"
        case .sunset:
            return "🌅"
        case .lavender:
            return "💜"
        case .autumn:
            return "🍂"
        case .cherry:
            return "🌸"
        case .arctic:
            return "❄️"
        case .coffee:
            return "☕"
        case .neon:
            return "⚡"
        }
    }
    
    var description: String {
        switch self {
        case .midnight:
            return "Dark and focused"
        case .ocean:
            return "Deep and calming"
        case .forest:
            return "Natural and refreshing"
        case .sunset:
            return "Warm and energizing"
        case .lavender:
            return "Dreamy and creative"
        case .autumn:
            return "Cozy and studious"
        case .cherry:
            return "Soft and elegant"
        case .arctic:
            return "Clean and minimal"
        case .coffee:
            return "Rich and warm"
        case .neon:
            return "Bold and electric"
        }
    }
}
