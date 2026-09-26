import Foundation

struct CoffeeRewards: Identifiable {
    let id = UUID()
    var points: Int
    var level: Int
    var streak: Int
    var totalCheckIns: Int
    var totalStudySessions: Int
    var uniqueCafesVisited: [String]
    var unlockedBadges: [String]
    
    var currentLevelName: String {
        switch level {
        case 1...2:
            return "Coffee Novice"
        case 3...5:
            return "Coffee Enthusiast"
        case 6...10:
            return "Coffee Connoisseur"
        case 11...15:
            return "Coffee Master"
        default:
            return "Coffee Legend"
        }
    }
    
    var pointsToNextLevel: Int {
        let pointsPerLevel = 100
        let currentLevelPoints = points % pointsPerLevel
        return pointsPerLevel - currentLevelPoints
    }
}
