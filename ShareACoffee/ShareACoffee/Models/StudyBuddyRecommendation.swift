import Foundation
import ShareACoffeeCore

/// Match reason category with icon and color
public enum MatchReasonCategory: String, CaseIterable, Codable {
    case sharedCourse = "Shared Course"
    case sameMajor = "Same Major"
    case sameCollege = "Same College"
    case nearbyLocation = "Nearby Location"
    case sameStudyHours = "Study Hours"
    case tutorMatch = "Tutor Match"
    case recentlyActive = "Recently Active"
    
    public var icon: String {
        switch self {
        case .sharedCourse: return "book.fill"
        case .sameMajor: return "graduationcap.fill"
        case .sameCollege: return "building.2.fill"
        case .nearbyLocation: return "mappin.circle.fill"
        case .sameStudyHours: return "clock.fill"
        case .tutorMatch: return "person.fill.badge.plus"
        case .recentlyActive: return "flame.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .sharedCourse: return "4488FF"
        case .sameMajor: return "FF44AA"
        case .sameCollege: return "44FFAA"
        case .nearbyLocation: return "FFAA44"
        case .sameStudyHours: return "AA44FF"
        case .tutorMatch: return "FF4444"
        case .recentlyActive: return "FFFF44"
        }
    }
}

/// Match reason details
public struct MatchReason: Identifiable, Codable {
    public let id: String = UUID().uuidString
    public let category: MatchReasonCategory
    public let description: String
    public let impact: Double
    
    public init(category: MatchReasonCategory, description: String, impact: Double) {
        self.category = category
        self.description = description
        self.impact = impact
    }
}

/// Detailed match features
public struct MatchFeatures: Codable {
    public var sharedCoursesCount: Int
    public var courseOverlapRatio: Double
    public var sameMajor: Bool
    public var sameCollege: Bool
    public var graduationYearDifference: Int
    public var distanceMiles: Double
    public var sameCity: Bool
    public var sameState: Bool
    public var studyHoursDifference: Int
    public var totalSessionsDifference: Int
    public var studyStreakSimilarity: Double
    public var bothRecentlyActive: Bool
    public var isTutorMatch: Bool
    public var hasOverlappingTutorSubjects: Bool
    public var accountAgeDays: Int
    public var lastActiveDaysDifference: Double
    
    public init(
        sharedCoursesCount: Int = 0,
        courseOverlapRatio: Double = 0,
        sameMajor: Bool = false,
        sameCollege: Bool = false,
        graduationYearDifference: Int = 0,
        distanceMiles: Double = 0,
        sameCity: Bool = false,
        sameState: Bool = false,
        studyHoursDifference: Int = 0,
        totalSessionsDifference: Int = 0,
        studyStreakSimilarity: Double = 0,
        bothRecentlyActive: Bool = false,
        isTutorMatch: Bool = false,
        hasOverlappingTutorSubjects: Bool = false,
        accountAgeDays: Int = 0,
        lastActiveDaysDifference: Double = 0
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

/// Study buddy recommendation
public struct StudyBuddyRecommendation: Identifiable, Codable {
    public let id: String
    public let user: User
    public let scorePercentage: Int
    public let compatibilityScore: Double
    public let matchReasons: [MatchReason]
    public let features: MatchFeatures
    public var isSwiped: Bool
    
    public init(
        id: String = UUID().uuidString,
        user: User,
        scorePercentage: Int = 75,
        compatibilityScore: Double = 0.75,
        matchReasons: [MatchReason] = [],
        features: MatchFeatures = MatchFeatures(),
        isSwiped: Bool = false
    ) {
        self.id = id
        self.user = user
        self.scorePercentage = scorePercentage
        self.compatibilityScore = compatibilityScore
        self.matchReasons = matchReasons
        self.features = features
        self.isSwiped = isSwiped
    }
}
