import Foundation

// MARK: - Match Model
struct Match: Identifiable, Codable, Equatable {
    let id: String
    let userId1: String
    let userId2: String
    var matchedAt: Date
    var isActive: Bool
    var lastMessageAt: Date?
    var unreadCount: Int
    
    init(
        id: String = UUID().uuidString,
        userId1: String,
        userId2: String,
        matchedAt: Date = Date(),
        isActive: Bool = true,
        lastMessageAt: Date? = nil,
        unreadCount: Int = 0
    ) {
        self.id = id
        self.userId1 = userId1
        self.userId2 = userId2
        self.matchedAt = matchedAt
        self.isActive = isActive
        self.lastMessageAt = lastMessageAt
        self.unreadCount = unreadCount
    }
    
    // Helper to check if user is part of this match
    func involves(userId: String) -> Bool {
        return userId1 == userId || userId2 == userId
    }
    
    // Get the other user's ID in the match
    func otherUserId(currentUserId: String) -> String {
        return userId1 == currentUserId ? userId2 : userId1
    }
}

// MARK: - Like Model
struct UserLike: Identifiable, Codable, Equatable {
    let id: String
    let userId: String // Person who liked
    let likedUserId: String // Person being liked
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        likedUserId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.likedUserId = likedUserId
        self.createdAt = createdAt
    }
}
