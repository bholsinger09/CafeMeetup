import SwiftUI

extension Color {
    // Dark Mode Background Colors
    static let darkBackground = Color(red: 0.15, green: 0.12, blue: 0.18)
    static let darkSecondary = Color(red: 0.20, green: 0.15, blue: 0.22)
    static let darkTertiary = Color(red: 0.25, green: 0.18, blue: 0.25)
    
    // Feminine Accent Colors
    static let primaryPink = Color(red: 0.85, green: 0.65, blue: 0.75)
    static let secondaryPink = Color(red: 0.75, green: 0.55, blue: 0.70)
    static let accentPink = Color(red: 0.75, green: 0.45, blue: 0.65)
    static let deepPink = Color(red: 0.65, green: 0.35, blue: 0.60)
    
    // Text Colors
    static let lightText = Color(red: 0.95, green: 0.85, blue: 0.90)
    static let secondaryText = Color(red: 0.85, green: 0.75, blue: 0.85)
    static let subtleText = Color(red: 0.85, green: 0.80, blue: 0.85)
    
    // Gradient Helpers
    static let primaryGradient = LinearGradient(
        colors: [primaryPink, secondaryPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [accentPink, deepPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [darkBackground, darkTertiary, darkSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
