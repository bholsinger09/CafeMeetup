import Foundation
import ShareACoffeeCore

// MARK: - Study Buddy Recommendation
/// Represents a recommended study partner with ML-powered compatibility scoring
public struct StudyBuddyRecommendation: Identifiable, Equatable {
    public let id: String
    public let user: User
    public let compatibilityScore: Double // 0.0 - 1.0
    public let matchReasons: [MatchReason]
    public let features: MatchFeatures
    public let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        user: User,
        compatibilityScore: Double,
        matchReasons: [MatchReason],
        features: MatchFeatures,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.user = user
        self.compatibilityScore = compatibilityScore
        self.matchReasons = matchReasons
        self.features = features
        self.timestamp = timestamp
    }
    
    /// User-friendly score display (0-100)
    public var scorePercentage: Int {
        Int(compatibilityScore * 100)
    }
    
    /// Score category for UI theming
    public var scoreCategory: ScoreCategory {
        switch compatibilityScore {
        case 0.9...1.0:
            return .excellent
        case 0.75..<0.9:
            return .great
        case 0.6..<0.75:
            return .good
        case 0.4..<0.6:
            return .fair
        default:
            return .low
        }
    }
    
    /// Top 3 reasons to display
    public var topReasons: [MatchReason] {
        Array(matchReasons.prefix(3))
    }
}

// MARK: - Score Category
public enum ScoreCategory: String {
    case excellent = "Excellent Match"
    case great = "Great Match"
    case good = "Good Match"
    case fair = "Fair Match"
    case low = "Possible Match"
    
    public var emoji: String {
        switch self {
        case .excellent: return "🌟"
        case .great: return "✨"
        case .good: return "👍"
        case .fair: return "👌"
        case .low: return "🤔"
        }
    }
    
    public var color: String {
        switch self {
        case .excellent: return "purple"
        case .great: return "blue"
        case .good: return "green"
        case .fair: return "orange"
        case .low: return "gray"
        }
    }
}

// MARK: - Match Reason
/// Explains why two users are compatible
public struct MatchReason: Identifiable, Equatable {
    public let id = UUID()
    public let category: ReasonCategory
    public let description: String
    public let impact: Double // How much this reason contributes to the score (0-1)
    
    public enum ReasonCategory: String, CaseIterable {
        case sharedCourse = "Shared Course"
        case sameMajor = "Same Major"
        case sameCollege = "Same College"
        case nearbyLocation = "Nearby Location"
        case similarSchedule = "Similar Schedule"
        case sharedInterests = "Shared Interests"
        case complementarySkills = "Complementary Skills"
        case studyHabits = "Study Habits"
        case academicLevel = "Academic Level"
        case recentlyActive = "Recently Active"
        
        public var icon: String {
            switch self {
            case .sharedCourse: return "book.fill"
            case .sameMajor: return "graduationcap.fill"
            case .sameCollege: return "building.columns.fill"
            case .nearbyLocation: return "map.fill"
            case .similarSchedule: return "clock.fill"
            case .sharedInterests: return "heart.fill"
            case .complementarySkills: return "person.2.fill"
            case .studyHabits: return "chart.bar.fill"
            case .academicLevel: return "star.fill"
            case .recentlyActive: return "circle.fill"
            }
        }
        
        public var color: String {
            switch self {
            case .sharedCourse: return "blue"
            case .sameMajor: return "purple"
            case .sameCollege: return "orange"
            case .nearbyLocation: return "green"
            case .similarSchedule: return "cyan"
            case .sharedInterests: return "pink"
            case .complementarySkills: return "indigo"
            case .studyHabits: return "teal"
            case .academicLevel: return "yellow"
            case .recentlyActive: return "mint"
            }
        }
    }
}

// MARK: - Match Features
/// Input features for ML model and rule-based matching
public struct MatchFeatures: Equatable {
    // Course & Academic Features
    public let sharedCoursesCount: Int
    public let courseOverlapRatio: Double // 0-1
    public let sameMajor: Bool
    public let sameCollege: Bool
    public let graduationYearDifference: Int
    
    // Location Features
    public let distanceMiles: Double
    public let sameCity: Bool
    public let sameState: Bool
    
    // Study Behavior Features
    public let studyHoursDifference: Int
    public let totalSessionsDifference: Int
    public let studyStreakSimilarity: Double // 0-1
    public let bothRecentlyActive: Bool
    
    // Tutoring Compatibility
    public let isTutorMatch: Bool // One is tutor, other needs help
    public let hasOverlappingTutorSubjects: Bool
    
    // Time & Availability
    public let accountAgeDays: Int
    public let lastActiveDaysDifference: Double
    
    // MARK: - Initializers
    
    /// Convenience initializer for production use - calculates features from user profiles
    init(currentUser: User, candidateUser: User, sharedCourses: Int) {
        // Course & Academic
        self.sharedCoursesCount = sharedCourses
        let currentCoursesCount = currentUser.currentCourses?.count ?? 0
        let candidateCoursesCount = candidateUser.currentCourses?.count ?? 0
        let totalUniqueCourses = currentCoursesCount + candidateCoursesCount - sharedCourses
        self.courseOverlapRatio = totalUniqueCourses > 0 ? Double(sharedCourses) / Double(totalUniqueCourses) : 0.0
        
        self.sameMajor = currentUser.major == candidateUser.major && currentUser.major != nil
        self.sameCollege = currentUser.college == candidateUser.college
        self.graduationYearDifference = abs((currentUser.graduationYear ?? 0) - (candidateUser.graduationYear ?? 0))
        
        // Location
        if let currentLoc = currentUser.location, let candidateLoc = candidateUser.location {
            self.distanceMiles = currentLoc.distance(to: candidateLoc)
        } else {
            self.distanceMiles = 999.0 // Unknown distance
        }
        self.sameCity = currentUser.city == candidateUser.city
        self.sameState = currentUser.state == candidateUser.state
        
        // Study Behavior
        self.studyHoursDifference = abs(currentUser.studyHoursThisWeek - candidateUser.studyHoursThisWeek)
        self.totalSessionsDifference = abs(currentUser.totalStudySessions - candidateUser.totalStudySessions)
        
        let maxStreak = max(Double(currentUser.studyStreak), Double(candidateUser.studyStreak))
        let minStreak = min(Double(currentUser.studyStreak), Double(candidateUser.studyStreak))
        self.studyStreakSimilarity = maxStreak > 0 ? minStreak / maxStreak : 0.0
        
        self.bothRecentlyActive = currentUser.isRecentlyActive && candidateUser.isRecentlyActive
        
        // Tutoring
        let currentSubjects = Set(currentUser.tutorSubjects ?? [])
        let candidateSubjects = Set(candidateUser.tutorSubjects ?? [])
        self.isTutorMatch = (currentUser.isTutor && !candidateUser.isTutor) || 
                           (!currentUser.isTutor && candidateUser.isTutor)
        self.hasOverlappingTutorSubjects = !currentSubjects.intersection(candidateSubjects).isEmpty
        
        // Time
        self.accountAgeDays = Int(Date().timeIntervalSince(candidateUser.createdAt) / 86400)
        
        let currentLastActive = currentUser.lastActiveAt ?? currentUser.createdAt
        let candidateLastActive = candidateUser.lastActiveAt ?? candidateUser.createdAt
        self.lastActiveDaysDifference = abs(currentLastActive.timeIntervalSince(candidateLastActive) / 86400)
    }
    
    /// Direct initializer for testing and previews
    init(
        sharedCoursesCount: Int,
        courseOverlapRatio: Double,
        sameMajor: Bool,
        sameCollege: Bool,
        graduationYearDifference: Int,
        distanceMiles: Double,
        sameCity: Bool,
        sameState: Bool,
        studyHoursDifference: Int,
        totalSessionsDifference: Int,
        studyStreakSimilarity: Double,
        bothRecentlyActive: Bool,
        isTutorMatch: Bool,
        hasOverlappingTutorSubjects: Bool,
        accountAgeDays: Int,
        lastActiveDaysDifference: Double
    ) {
        self.sharedCoursesCount = sharedCoursesCount
        self.courseOverlapRatio = courseOverlapRatio
        self.sameMajor = sameMajor
        self.sameCollege = sameCollege
        self.graduationYearDifference = graduationYearDifference
        self.distanceMiles = distanceMiles
        self.sameCity = sameCity
        self.sameState = sameState
        self.studyHoursDifference = studyHoursDifference
        self.totalSessionsDifference = totalSessionsDifference
        self.studyStreakSimilarity = studyStreakSimilarity
        self.bothRecentlyActive = bothRecentlyActive
        self.isTutorMatch = isTutorMatch
        self.hasOverlappingTutorSubjects = hasOverlappingTutorSubjects
        self.accountAgeDays = accountAgeDays
        self.lastActiveDaysDifference = lastActiveDaysDifference
    }
}

// MARK: - Swipe Action
/// User action on a recommendation card
enum SwipeAction {
    case like // Swipe right
    case pass // Swipe left
    case superLike // Swipe up (future feature)
}

// MARK: - Recommendation Filter Preferences
/// User preferences for filtering recommendations
struct RecommendationFilters {
    public var maxDistance: Double? // Miles
    public var sameMajorOnly: Bool
    public var sameCollegeOnly: Bool
    public var minCompatibilityScore: Double
    public var requireSharedCourses: Bool
    public var onlyRecentlyActive: Bool
    
    static let `default` = RecommendationFilters(
        maxDistance: nil,
        sameMajorOnly: false,
        sameCollegeOnly: false,
        minCompatibilityScore: 0.4,
        requireSharedCourses: false,
        onlyRecentlyActive: false
    )
}
