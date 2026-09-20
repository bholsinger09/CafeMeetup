import SwiftUI
import Combine

/// Extensions for color and gradient management
extension Color {
    /// Primary pink color for the app
    public static let primaryPink = Color(red: 1.0, green: 0.2, blue: 0.6)
    
    /// Dark secondary color
    public static let darkSecondary = Color(red: 0.2, green: 0.2, blue: 0.3)
    
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
    
    public nonisolated(unsafe) static let shared = ThemeManager()
    
    override private init() {}
}

/// App theme enumeration
public enum AppTheme {
    case light
    case dark
    
    /// Primary accent color for the theme
    public var accentColor: Color {
        return Color.primaryPink
    }
    
    /// Card background color
    public var cardBackgroundColor: Color {
        switch self {
        case .light:
            return Color(red: 0.95, green: 0.95, blue: 1.0)
        case .dark:
            return Color(red: 0.2, green: 0.2, blue: 0.3)
        }
    }
    
    /// Primary gradient
    public var primaryGradient: LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [Color.primaryPink, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
