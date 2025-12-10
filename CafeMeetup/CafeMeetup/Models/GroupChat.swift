import Foundation

/// GroupChat - For study groups of 3+ people
/// Emphasizes academic collaboration over 1-on-1 messaging
struct GroupChat: Identifiable, Codable, Equatable {
    let id: String
    var name: String // e.g., "CS 101 Study Group"
    var memberIds: [String] // User IDs
    var memberNames: [String: String] // [userId: userName]
    var courseCode: String? // Associated course if applicable
    let createdBy: String // Host user ID
    let createdAt: Date
    var lastMessageAt: Date?
    var studySessionId: String? // If created for a specific study session
    var isActive: Bool
    
    init(
        id: String = UUID().uuidString,
        name: String,
        memberIds: [String],
        memberNames: [String: String] = [:],
        courseCode: String? = nil,
        createdBy: String,
        createdAt: Date = Date(),
        lastMessageAt: Date? = nil,
        studySessionId: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.memberIds = memberIds
        self.memberNames = memberNames
        self.courseCode = courseCode
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.lastMessageAt = lastMessageAt
        self.studySessionId = studySessionId
        self.isActive = isActive
    }
    
    var memberCount: Int {
        memberIds.count
    }
    
    var displayName: String {
        if let course = courseCode {
            return "\(course) - \(name)"
        }
        return name
    }
    
    var isGroupChat: Bool {
        memberIds.count >= 3
    }
}

/// GroupMessage - Messages within a group chat
struct GroupMessage: Identifiable, Codable, Equatable {
    let id: String
    let groupChatId: String
    let senderId: String
    var senderName: String
    let content: String
    let timestamp: Date
    var isRead: [String: Bool] // [userId: hasRead]
    var messageType: MessageType
    var attachmentURL: String? // For shared study materials
    
    enum MessageType: String, Codable {
        case text = "text"
        case image = "image"
        case file = "file" // Study materials, notes, PDFs
        case systemNotification = "system" // "Sarah joined the group"
    }
    
    init(
        id: String = UUID().uuidString,
        groupChatId: String,
        senderId: String,
        senderName: String,
        content: String,
        timestamp: Date = Date(),
        isRead: [String: Bool] = [:],
        messageType: MessageType = .text,
        attachmentURL: String? = nil
    ) {
        self.id = id
        self.groupChatId = groupChatId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageType = messageType
        self.attachmentURL = attachmentURL
    }
}
