import Foundation
import ShareACoffeeCore

struct BlogPost: Identifiable, Codable {
    public let id: String
    public let authorId: String
    public var authorName: String
    public var authorImageURL: String?
    public var title: String
    public var content: String
    public var tags: [String]
    public var coffeeShopId: String?
    public var coffeeShopName: String?
    public var meetupDate: Date?
    public var location: User.Location?
    public var images: [String]
    public var likeCount: Int
    public var commentCount: Int
    public var meetupInterestCount: Int
    public var createdAt: Date
    public var updatedAt: Date
    
    // Study meetup specific fields
    public var studyCourse: String? // e.g., "CS 101", "MATH 250"
    public var studyTopic: String? // e.g., "Midterm Review", "Chapter 5"
    public var isStudyMeetup: Bool = false // Flag for study-focused posts
    public var maxAttendees: Int? // For group study meetups
    
    init(
        id: String = UUID().uuidString,
        authorId: String,
        authorName: String,
        authorImageURL: String? = nil,
        title: String,
        content: String,
        tags: [String] = [],
        coffeeShopId: String? = nil,
        coffeeShopName: String? = nil,
        meetupDate: Date? = nil,
        location: User.Location? = nil,
        images: [String] = [],
        likeCount: Int = 0,
        commentCount: Int = 0,
        meetupInterestCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        studyCourse: String? = nil,
        studyTopic: String? = nil,
        isStudyMeetup: Bool = false,
        maxAttendees: Int? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorImageURL = authorImageURL
        self.title = title
        self.content = content
        self.tags = tags
        self.coffeeShopId = coffeeShopId
        self.coffeeShopName = coffeeShopName
        self.meetupDate = meetupDate
        self.location = location
        self.images = images
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.meetupInterestCount = meetupInterestCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.studyCourse = studyCourse
        self.studyTopic = studyTopic
        self.isStudyMeetup = isStudyMeetup
        self.maxAttendees = maxAttendees
    }
}

// MARK: - Equatable Conformance
extension BlogPost {
    static func == (lhs: BlogPost, rhs: BlogPost) -> Bool {
        return lhs.id == rhs.id &&
               lhs.authorId == rhs.authorId &&
               lhs.authorName == rhs.authorName &&
               lhs.authorImageURL == rhs.authorImageURL &&
               lhs.title == rhs.title &&
               lhs.content == rhs.content &&
               lhs.tags == rhs.tags &&
               lhs.coffeeShopId == rhs.coffeeShopId &&
               lhs.coffeeShopName == rhs.coffeeShopName &&
               lhs.meetupDate == rhs.meetupDate &&
               lhs.location == rhs.location &&
               lhs.images == rhs.images &&
               lhs.likeCount == rhs.likeCount &&
               lhs.commentCount == rhs.commentCount &&
               lhs.meetupInterestCount == rhs.meetupInterestCount &&
               lhs.createdAt == rhs.createdAt &&
               lhs.updatedAt == rhs.updatedAt &&
               lhs.studyCourse == rhs.studyCourse &&
               lhs.studyTopic == rhs.studyTopic &&
               lhs.isStudyMeetup == rhs.isStudyMeetup &&
               lhs.maxAttendees == rhs.maxAttendees
    }
}

// MARK: - Comment
struct Comment: Identifiable, Codable, Equatable {
    public let id: String
    public let postId: String
    public let authorId: String
    public var authorName: String
    public var authorImageURL: String?
    public var content: String
    public var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        postId: String,
        authorId: String,
        authorName: String,
        authorImageURL: String? = nil,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.authorName = authorName
        self.authorImageURL = authorImageURL
        self.content = content
        self.createdAt = createdAt
    }
}

// MARK: - Like
struct Like: Identifiable, Codable, Equatable {
    public let id: String
    public let postId: String
    public let userId: String
    public var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        postId: String,
        userId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.createdAt = createdAt
    }
}

// MARK: - MeetupInterest
struct MeetupInterest: Identifiable, Codable, Equatable {
    public let id: String
    public let postId: String
    public let userId: String
    public var userName: String
    public var userEmail: String
    public var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        postId: String,
        userId: String,
        userName: String,
        userEmail: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.createdAt = createdAt
    }
}
