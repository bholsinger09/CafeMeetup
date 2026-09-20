import Foundation
import CoreLocation

/// Study Session - Primary feature for academic collaboration at coffee shops
/// Students organize GROUP study sessions (3+ people) to work on coursework together
public struct StudySession: Identifiable, Codable, Equatable {
    public let id: String
    public let hostId: String
    public var hostName: String
    public let courseCode: String // e.g., "CS 101", "MATH 250"
    public let courseName: String // e.g., "Introduction to Programming"
    public let studyTopic: String // e.g., "Chapter 5: Loops", "Midterm Review"
    public let cafeId: String
    public var cafeName: String
    public let scheduledDate: Date
    public let duration: Int // minutes (typically 60-180)
    public var attendeeIds: [String] // User IDs of students who joined
    public var attendeeNames: [String: String] // [userId: userName] for display
    public let minAttendees: Int // Minimum for session to happen (default 3)
    public let maxAttendees: Int // Maximum capacity (3-8 people)
    public let isPublic: Bool // Public sessions visible to all students in same course
    public var status: SessionStatus
    public let createdAt: Date
    public var studyMaterials: [String]? // URLs or descriptions of materials needed
    public var groupChatId: String? // Reference to group chat for this session
    public var completedAttendees: [String]? // Who checked in/completed the session
    
    public enum SessionStatus: String, Codable {
        case scheduled = "Scheduled"
        case active = "Active"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
    
    public init(
        id: String = UUID().uuidString,
        hostId: String,
        hostName: String,
        courseCode: String,
        courseName: String,
        studyTopic: String,
        cafeId: String,
        cafeName: String,
        scheduledDate: Date,
        duration: Int = 120,
        attendeeIds: [String] = [],
        attendeeNames: [String: String] = [:],
        minAttendees: Int = 3,
        maxAttendees: Int = 6,
        isPublic: Bool = true,
        status: SessionStatus = .scheduled,
        createdAt: Date = Date(),
        studyMaterials: [String]? = nil,
        groupChatId: String? = nil,
        completedAttendees: [String]? = nil
    ) {
        self.id = id
        self.hostId = hostId
        self.hostName = hostName
        self.courseCode = courseCode
        self.courseName = courseName
        self.studyTopic = studyTopic
        self.cafeId = cafeId
        self.cafeName = cafeName
        self.scheduledDate = scheduledDate
        self.duration = duration
        self.attendeeIds = attendeeIds
        self.attendeeNames = attendeeNames
        self.minAttendees = minAttendees
        self.maxAttendees = maxAttendees
        self.isPublic = isPublic
        self.status = status
        self.createdAt = createdAt
        self.studyMaterials = studyMaterials
        self.groupChatId = groupChatId
        self.completedAttendees = completedAttendees
    }
    
    public var isUpcoming: Bool {
        scheduledDate > Date()
    }
    
    public var isFull: Bool {
        attendeeIds.count >= maxAttendees
    }
    
    public var hasMinimumAttendees: Bool {
        attendeeIds.count >= minAttendees
    }
    
    public var availableSpots: Int {
        maxAttendees - attendeeIds.count
    }
    
    public var displayCourse: String {
        "\(courseCode): \(courseName)"
    }
    
    public var isGroupSession: Bool {
        maxAttendees >= 3
    }
}

/// Study subjects popular among college students
public enum StudySubject: String, CaseIterable {
    case mathematics = "Mathematics"
    case science = "Science"
    case engineering = "Engineering"
    case computerScience = "Computer Science"
    case business = "Business"
    case english = "English"
    case history = "History"
    case psychology = "Psychology"
    case biology = "Biology"
    case chemistry = "Chemistry"
    case physics = "Physics"
    case economics = "Economics"
    case languages = "Languages"
    case art = "Art"
    case music = "Music"
    case other = "Other"
    
    public var emoji: String {
        switch self {
        case .mathematics: return "➗"
        case .science: return "🔬"
        case .engineering: return "⚙️"
        case .computerScience: return "💻"
        case .business: return "💼"
        case .english: return "📖"
        case .history: return "🏛️"
        case .psychology: return "🧠"
        case .biology: return "🧬"
        case .chemistry: return "⚗️"
        case .physics: return "⚛️"
        case .economics: return "📈"
        case .languages: return "🗣️"
        case .art: return "🎨"
        case .music: return "🎵"
        case .other: return "📚"
        }
    }
}

/// Café Check-in - Unique feature to verify actual coffee dates
/// Users get rewards and badges for meeting up in person
public struct CafeCheckIn: Identifiable, Codable {
    public let id: String
    public let userId: String
    public let cafeId: String
    public var cafeName: String
    public let location: CLLocationCoordinate2D
    public let timestamp: Date
    public var matchId: String? // If checking in with a match
    public var studySessionId: String? // If part of a study session
    public let coffeeOrdered: String?
    public var photoUrl: String? // Optional photo from the date
    public var rating: Int? // 1-5 stars for the experience
    public var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, userId, cafeId, cafeName, timestamp, matchId, studySessionId
        case coffeeOrdered, photoUrl, rating, notes
        case latitude, longitude
    }
    
    init(id: String, userId: String, cafeId: String, cafeName: String, location: CLLocationCoordinate2D, timestamp: Date, matchId: String? = nil, studySessionId: String? = nil, coffeeOrdered: String? = nil) {
        self.id = id
        self.userId = userId
        self.cafeId = cafeId
        self.cafeName = cafeName
        self.location = location
        self.timestamp = timestamp
        self.matchId = matchId
        self.studySessionId = studySessionId
        self.coffeeOrdered = coffeeOrdered
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        cafeId = try container.decode(String.self, forKey: .cafeId)
        cafeName = try container.decode(String.self, forKey: .cafeName)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        matchId = try container.decodeIfPresent(String.self, forKey: .matchId)
        studySessionId = try container.decodeIfPresent(String.self, forKey: .studySessionId)
        coffeeOrdered = try container.decodeIfPresent(String.self, forKey: .coffeeOrdered)
        photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(cafeId, forKey: .cafeId)
        try container.encode(cafeName, forKey: .cafeName)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(matchId, forKey: .matchId)
        try container.encodeIfPresent(studySessionId, forKey: .studySessionId)
        try container.encodeIfPresent(coffeeOrdered, forKey: .coffeeOrdered)
        try container.encodeIfPresent(photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
    }
}

/// Coffee Rewards - Gamification system unique to StudyBrew
struct CoffeeRewards: Codable {
    public var points: Int
    public var level: Int
    public var streak: Int // consecutive days of activity
    public var totalCheckIns: Int
    public var totalStudySessions: Int
    public var uniqueCafesVisited: Set<String>
    public var unlockedBadges: [String] // Badge IDs
    
    public var pointsToNextLevel: Int {
        (level + 1) * 100 - points
    }
    
    public var currentLevelName: String {
        switch level {
        case 0...5: return "Coffee Newbie"
        case 6...10: return "Café Regular"
        case 11...20: return "Espresso Enthusiast"
        case 21...30: return "Latte Artist"
        case 31...50: return "Barista Expert"
        default: return "Coffee Legend"
        }
    }
    
    mutating func addPoints(_ amount: Int) {
        points += amount
        updateLevel()
    }
    
    private mutating func updateLevel() {
        let newLevel = points / 100
        if newLevel > level {
            level = newLevel
        }
    }
}
