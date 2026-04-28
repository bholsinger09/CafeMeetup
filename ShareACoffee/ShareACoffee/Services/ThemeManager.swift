import Foundation
import SwiftUI
import Combine

/// Manages theme selection and persistence
@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    
    @Published var isPremiumUser: Bool = false
    
    private let themeKey = "selectedAppTheme"
    
    private init() {
        // Load saved theme or default to midnight
        if let savedThemeRawValue = UserDefaults.standard.string(forKey: themeKey),
           let savedTheme = AppTheme(rawValue: savedThemeRawValue) {
            self.currentTheme = savedTheme
        } else {
            self.currentTheme = .midnight
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        // Check if premium theme and user has access
        if theme.isPremium && !isPremiumUser {
            // Handle premium upgrade prompt
            return
        }
        currentTheme = theme
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    func unlockPremiumThemes() {
        isPremiumUser = true
    }
}

/// Achievement tracking and management
@MainActor
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = []
    @Published var recentlyUnlocked: Achievement?
    
    private let achievementsKey = "userAchievements"
    
    private init() {
        loadAchievements()
    }
    
    func loadAchievements() {
        // Load from UserDefaults (in production, sync with backend)
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            // Initialize with default achievements
            achievements = Achievement.allAchievements
        }
    }
    
    func updateProgress(for category: AchievementCategory, value: Int) {
        for index in achievements.indices {
            if achievements[index].category == category && !achievements[index].isUnlocked {
                achievements[index].progress = value
                
                // Check if unlocked
                if achievements[index].progress >= achievements[index].requirement {
                    unlockAchievement(at: index)
                }
            }
        }
        saveAchievements()
    }
    
    private func unlockAchievement(at index: Int) {
        achievements[index].unlockedAt = Date()
        recentlyUnlocked = achievements[index]
        
        // Trigger celebration animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.recentlyUnlocked = nil
        }
    }
    
    func recordStudyHour(hours: Int) {
        updateProgress(for: .study, value: hours)
    }
    
    func recordStreak(days: Int) {
        updateProgress(for: .streak, value: days)
    }
    
    func recordSession() {
        let sessionCount = achievements.first(where: { $0.category == .session })?.progress ?? 0
        updateProgress(for: .session, value: sessionCount + 1)
    }
    
    func recordMatch() {
        let matchCount = achievements.first(where: { $0.category == .social })?.progress ?? 0
        updateProgress(for: .social, value: matchCount + 1)
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
    
    var completionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }
}
