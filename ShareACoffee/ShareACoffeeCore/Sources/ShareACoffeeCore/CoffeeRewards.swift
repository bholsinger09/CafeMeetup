import Foundation

/// Coffee rewards and points system
public struct CoffeeRewards: Codable {
    public var points: Int
    public var level: Int
    public var streak: Int
    public var totalCheckIns: Int
    public var totalStudySessions: Int
    public var uniqueCafesVisited: [String]
    public var unlockedBadges: [String]
    
    public init(
        points: Int = 0,
        level: Int = 0,
        streak: Int = 0,
        totalCheckIns: Int = 0,
        totalStudySessions: Int = 0,
        uniqueCafesVisited: [String] = [],
        unlockedBadges: [String] = []
    ) {
        self.points = points
        self.level = level
        self.streak = streak
        self.totalCheckIns = totalCheckIns
        self.totalStudySessions = totalStudySessions
        self.uniqueCafesVisited = uniqueCafesVisited
        self.unlockedBadges = unlockedBadges
    }
}
