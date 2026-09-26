import Foundation

/// Blog post model
public struct BlogPost: Identifiable, Codable {
    public let id: String
    public let userId: String
    public let authorId: String  // Alias for userId
    public let authorName: String
    public var title: String
    public var content: String
    public var tags: [String]
    public var coffeeShopId: String?
    public var coffeeShopName: String?
    public var meetupDate: Date?
    public let createdAt: Date
    public var updatedAt: Date
    public var studyCourse: String?
    public var studyTopic: String?
    public var isStudyMeetup: Bool = false
    public var maxAttendees: Int?
    public var likeCount: Int = 0
    public var commentCount: Int = 0
    public var meetupInterestCount: Int = 0
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        authorName: String,
        title: String,
        content: String,
        tags: [String] = [],
        coffeeShopId: String? = nil,
        coffeeShopName: String? = nil,
        meetupDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        studyCourse: String? = nil,
        studyTopic: String? = nil,
        isStudyMeetup: Bool = false,
        maxAttendees: Int? = nil,
        likeCount: Int = 0,
        commentCount: Int = 0,
        meetupInterestCount: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.authorId = userId  // Set authorId to same as userId
        self.authorName = authorName
        self.title = title
        self.content = content
        self.tags = tags
        self.coffeeShopId = coffeeShopId
        self.coffeeShopName = coffeeShopName
        self.meetupDate = meetupDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.studyCourse = studyCourse
        self.studyTopic = studyTopic
        self.isStudyMeetup = isStudyMeetup
        self.maxAttendees = maxAttendees
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.meetupInterestCount = meetupInterestCount
    }
}
