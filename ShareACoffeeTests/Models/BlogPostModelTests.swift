import XCTest
@testable import CafeMeetup

final class BlogPostModelTests: XCTestCase {
    
    func testBlogPostInitialization() {
        let post = BlogPost(
            authorId: "user123",
            authorName: "John Doe",
            title: "Coffee Meetup This Weekend",
            content: "Let's meet at Starbucks!"
        )
        
        XCTAssertEqual(post.authorId, "user123")
        XCTAssertEqual(post.authorName, "John Doe")
        XCTAssertEqual(post.title, "Coffee Meetup This Weekend")
        XCTAssertEqual(post.content, "Let's meet at Starbucks!")
        XCTAssertEqual(post.tags, [])
        XCTAssertEqual(post.likeCount, 0)
        XCTAssertEqual(post.commentCount, 0)
    }
    
    func testBlogPostWithAllFields() {
        let location = Location(latitude: 34.0522, longitude: -118.2437)
        let meetupDate = Date()
        
        let post = BlogPost(
            authorId: "user123",
            authorName: "John Doe",
            title: "Coffee Meetup",
            content: "Join us!",
            tags: ["Meetup", "Coffee"],
            coffeeShopId: "shop456",
            coffeeShopName: "Starbucks",
            meetupDate: meetupDate,
            location: location,
            likeCount: 10,
            commentCount: 5
        )
        
        XCTAssertEqual(post.tags.count, 2)
        XCTAssertTrue(post.tags.contains("Meetup"))
        XCTAssertTrue(post.tags.contains("Coffee"))
        XCTAssertEqual(post.coffeeShopId, "shop456")
        XCTAssertEqual(post.coffeeShopName, "Starbucks")
        XCTAssertNotNil(post.meetupDate)
        XCTAssertNotNil(post.location)
        XCTAssertEqual(post.likeCount, 10)
        XCTAssertEqual(post.commentCount, 5)
    }
    
    func testCommentInitialization() {
        let comment = Comment(
            postId: "post123",
            authorId: "user456",
            authorName: "Jane Smith",
            content: "Sounds great!"
        )
        
        XCTAssertEqual(comment.postId, "post123")
        XCTAssertEqual(comment.authorId, "user456")
        XCTAssertEqual(comment.authorName, "Jane Smith")
        XCTAssertEqual(comment.content, "Sounds great!")
    }
    
    func testLikeInitialization() {
        let like = Like(
            postId: "post123",
            userId: "user789"
        )
        
        XCTAssertEqual(like.postId, "post123")
        XCTAssertEqual(like.userId, "user789")
    }
}
