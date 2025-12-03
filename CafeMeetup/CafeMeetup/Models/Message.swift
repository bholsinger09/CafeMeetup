import Foundation

// MARK: - Message Model
struct Message: Identifiable, Codable, Equatable {
    let id: String
    let senderId: String
    let receiverId: String
    var content: String
    var sentAt: Date
    var readAt: Date?
    var isPriority: Bool
    var giftType: GiftType?
    
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
    
    var isRead: Bool {
        return readAt != nil
    }
    
    var isGift: Bool {
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
    
    var displayName: String {
        switch self {
        case .coffee: return "Coffee"
        case .heart: return "Heart"
        case .rose: return "Rose"
        case .cake: return "Cake"
        case .star: return "Star"
        case .sparkles: return "Sparkles"
        }
    }
    
    var emoji: String {
        return self.rawValue
    }
}

// MARK: - Icebreaker Questions
struct IcebreakerQuestion {
    let question: String
    
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
