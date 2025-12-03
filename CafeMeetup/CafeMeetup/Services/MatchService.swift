import Foundation

protocol MatchServiceProtocol {
    func addLike(userId: String, likedUserId: String) async throws -> Bool // Returns true if it's a match
    func removeLike(userId: String, likedUserId: String) async throws
    func hasLiked(userId: String, likedUserId: String) async throws -> Bool
    func getMatches(forUserId userId: String) async throws -> [Match]
    func unmatch(matchId: String) async throws
}

class MatchService: MatchServiceProtocol {
    static let shared = MatchService()
    
    private init() {}
    
    private var likes: [UserLike] = []
    private var matches: [Match] = []
    
    func addLike(userId: String, likedUserId: String) async throws -> Bool {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Check if already liked
        if likes.contains(where: { $0.userId == userId && $0.likedUserId == likedUserId }) {
            return false
        }
        
        // Add the like
        let like = UserLike(userId: userId, likedUserId: likedUserId)
        likes.append(like)
        print("[MatchService] \(userId) liked \(likedUserId)")
        
        // Check for mutual like
        let mutualLike = likes.contains(where: { $0.userId == likedUserId && $0.likedUserId == userId })
        
        if mutualLike {
            // Create a match
            let match = Match(userId1: userId, userId2: likedUserId)
            matches.append(match)
            print("[MatchService] ✅ MATCH CREATED between \(userId) and \(likedUserId)")
            return true
        }
        
        return false
    }
    
    func removeLike(userId: String, likedUserId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        likes.removeAll(where: { $0.userId == userId && $0.likedUserId == likedUserId })
        print("[MatchService] Removed like from \(userId) to \(likedUserId)")
    }
    
    func hasLiked(userId: String, likedUserId: String) async throws -> Bool {
        return likes.contains(where: { $0.userId == userId && $0.likedUserId == likedUserId })
    }
    
    func getMatches(forUserId userId: String) async throws -> [Match] {
        try await Task.sleep(nanoseconds: 300_000_000)
        let userMatches = matches.filter { $0.involves(userId: userId) && $0.isActive }
        print("[MatchService] Found \(userMatches.count) matches for user \(userId)")
        return userMatches.sorted(by: { $0.matchedAt > $1.matchedAt })
    }
    
    func unmatch(matchId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        if let index = matches.firstIndex(where: { $0.id == matchId }) {
            matches[index].isActive = false
            print("[MatchService] Unmatched: \(matchId)")
        }
    }
    
    // Helper method to get all likes for debugging
    func getAllLikes() -> [UserLike] {
        return likes
    }
    
    // Helper method to update match with last message info
    func updateMatch(matchId: String, lastMessageAt: Date, incrementUnreadFor userId: String) {
        if let index = matches.firstIndex(where: { $0.id == matchId }) {
            matches[index].lastMessageAt = lastMessageAt
            // Increment unread count for the receiver
            let match = matches[index]
            if match.otherUserId(currentUserId: userId) == userId {
                matches[index].unreadCount += 1
            }
        }
    }
    
    func clearUnreadCount(matchId: String) {
        if let index = matches.firstIndex(where: { $0.id == matchId }) {
            matches[index].unreadCount = 0
        }
    }
}
