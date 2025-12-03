import Foundation

struct BlogPost: Identifiable, Codable, Equatable {
    let id: String
    let authorId: String
    var authorName: String
    var authorImageURL: String?
    var title: String
    var content: String
    var tags: [String]
    var coffeeShopId: String?
    var coffeeShopName: String?
    var meetupDate: Date?
    var location: Location?
    var images: [String]
    var likeCount: Int
    var commentCount: Int
    var createdAt: Date
    var updatedAt: Date
    
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
        location: Location? = nil,
        images: [String] = [],
        likeCount: Int = 0,
        commentCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Comment
struct Comment: Identifiable, Codable, Equatable {
    let id: String
    let postId: String
    let authorId: String
    var authorName: String
    var authorImageURL: String?
    var content: String
    var createdAt: Date
    
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
    let id: String
    let postId: String
    let userId: String
    var createdAt: Date
    
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
