import Foundation

// MARK: - Message Model
struct Message: Identifiable, Codable, Equatable {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public var content: String
    public var sentAt: Date
    public var readAt: Date?
    public var isPriority: Bool
    public var giftType: GiftType?
    
    init(
        id: String = UUID().uuidString,
        senderId: String,
        receiverId: String,
        content: String,
        sentAt: Date = Date(),
        readAt: Date? = nil,
        isPriority: Bool = false,
        giftType: GiftType? = nil
    ) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.sentAt = sentAt
        self.readAt = readAt
        self.isPriority = isPriority
        self.giftType = giftType
    }
    
    public var isRead: Bool {
        return readAt != nil
    }
    
    public var isGift: Bool {
        return giftType != nil
    }
}

// MARK: - Gift Types
enum GiftType: String, Codable, CaseIterable {
    case coffee = "☕️"
    case heart = "❤️"
    case rose = "🌹"
    case cake = "🎂"
    case star = "⭐️"
    case sparkles = "✨"
    
    public var displayName: String {
        switch self {
        case .coffee: return "Coffee"
        case .heart: return "Heart"
        case .rose: return "Rose"
        case .cake: return "Cake"
        case .star: return "Star"
        case .sparkles: return "Sparkles"
        }
    }
    
    public var emoji: String {
        return self.rawValue
    }
}

// MARK: - Icebreaker Questions
struct IcebreakerQuestion {
    public let question: String
    
    static let questions = [
        "What's your favorite coffee order?",
        "Best coffee shop you've been to?",
        "Coffee or tea?",
        "What's your go-to study spot?",
        "Favorite thing about your college?",
        "What are you studying?",
        "Morning person or night owl?",
        "What's on your bucket list?",
        "Favorite local hangout?",
        "What's your hidden talent?",
        "Dream vacation destination?",
        "Favorite way to unwind?",
        "Best concert you've been to?",
        "What motivates you?",
        "Favorite book or movie?",
        "What makes you laugh?",
        "Spontaneous or planner?",
        "What's your superpower?",
        "Favorite season and why?",
        "What are you passionate about?"
    ]
    
    static func random() -> String {
        return questions.randomElement() ?? questions[0]
    }
}
