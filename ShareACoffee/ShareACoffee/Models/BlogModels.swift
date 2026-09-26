import Foundation
import ShareACoffeeCore

/// Comment on a blog post
public struct Comment: Identifiable, Codable {
    public let id: String
    public let postId: String
    public let authorId: String
    public let authorName: String
    public let authorImageURL: String?
    public var content: String
    public var likeCount: Int
    public let createdAt: Date
    public var updatedAt: Date?
    
    public init(
        id: String = UUID().uuidString,
        postId: String,
        authorId: String,
        authorName: String,
        authorImageURL: String? = nil,
        content: String,
        likeCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.authorName = authorName
        self.authorImageURL = authorImageURL
        self.content = content
        self.likeCount = likeCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Meetup interest on a blog post
public struct MeetupInterest: Identifiable, Codable {
    public let id: String
    public let postId: String
    public let userId: String
    public let userName: String
    public let userEmail: String
    public let userImageURL: String?
    public let createdAt: Date
    public let interestedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        postId: String,
        userId: String,
        userName: String,
        userEmail: String,
        userImageURL: String? = nil,
        createdAt: Date = Date(),
        interestedAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.userImageURL = userImageURL
        self.createdAt = createdAt
        self.interestedAt = interestedAt
    }
}
