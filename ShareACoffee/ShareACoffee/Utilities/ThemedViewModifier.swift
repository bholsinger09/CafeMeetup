import SwiftUI

/// ViewModifier that applies the current theme to views
struct ThemedViewModifier: ViewModifier {
    @ObservedObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(themeManager.currentTheme.gradientColors.first?.opacity(0.05) ?? Color.clear)
            .tint(themeManager.currentTheme.accentColor)
            .preferredColorScheme(.dark) // Keep dark mode consistent
    }
}

extension View {
    @MainActor
    func applyTheme(_ themeManager: ThemeManager = .shared) -> some View {
        self.modifier(ThemedViewModifier(themeManager: themeManager))
    }
}
