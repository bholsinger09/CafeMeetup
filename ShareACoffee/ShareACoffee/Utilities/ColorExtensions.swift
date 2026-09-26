import SwiftUI
import Combine

/// Extensions for color and gradient management
extension Color {
    /// Primary pink color for the app
    public static let primaryPink = Color(red: 1.0, green: 0.2, blue: 0.6)
    
    /// Dark secondary color
    public static let darkSecondary = Color(red: 0.2, green: 0.2, blue: 0.3)
    
    /// Dark background color
    public static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    
    /// Light text color
    public static let lightText = Color(red: 0.7, green: 0.7, blue: 0.7)
    
    /// Secondary text color
    public static let secondary = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    /// Primary gradient
    public static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color.primaryPink, Color.purple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Background gradient
    public static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white, Color(red: 0.95, green: 0.95, blue: 1.0)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// Theme management
public final class ThemeManager: NSObject, ObservableObject {
    @Published public var currentTheme: AppTheme = .light
    @Published public var isPremiumUser: Bool = false
    
    public nonisolated(unsafe) static let shared = ThemeManager()
    
    override private init() {}
    
    public func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    public func unlockPremiumThemes() {
        isPremiumUser = true
    }
}

/// App theme enumeration
public enum AppTheme: String, CaseIterable, Equatable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case sunset = "Sunset"
    case midnight = "Midnight"
    case forest = "Forest"
    case ocean = "Ocean"
    
    public var id: String { rawValue }
    
    public var isPremium: Bool {
        switch self {
        case .light, .dark:
            return false
        case .sunset, .midnight, .forest, .ocean:
            return true
        }
    }
    
    public var emoji: String {
        switch self {
        case .light:
            return "☀️"
        case .dark:
            return "🌙"
        case .sunset:
            return "🌅"
        case .midnight:
            return "⭐"
        case .forest:
            return "🌲"
        case .ocean:
            return "🌊"
        }
    }
    
    public var description: String {
        rawValue
    }
    
    /// Primary accent color for the theme
    public var accentColor: Color {
        return Color.primaryPink
    }
    
    /// Card background color
    public var cardBackgroundColor: Color {
        switch self {
        case .light, .sunset:
            return Color(red: 0.95, green: 0.95, blue: 1.0)
        case .dark, .midnight, .forest, .ocean:
            return Color(red: 0.2, green: 0.2, blue: 0.3)
        }
    }
    
    /// Primary gradient
    public var primaryGradient: LinearGradient {
        switch self {
        case .light:
            return LinearGradient(
                gradient: Gradient(colors: [Color.primaryPink, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunset:
            return LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .midnight:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .forest:
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color(red: 0.1, green: 0.3, blue: 0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ocean:
            return LinearGradient(
                gradient: Gradient(colors: [Color.cyan, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
