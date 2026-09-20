import XCTest
@testable import ShareACoffeeBlog
import ShareACoffeeCore

final class ShareACoffeeBlogTests: XCTestCase {
    
    func testBlogPostModelInitialization() {
        let blogPost = BlogPost(
            id: "post-1",
            authorId: "author-123",
            authorName: "Alice Johnson",
            authorImageURL: nil,
            title: "Top 10 Coffee Shops for Studying",
            content: "Here are the best coffee shops for productive studying...",
            tags: ["coffee", "study", "productivity"],
            coffeeShopId: nil,
            coffeeShopName: nil,
            meetupDate: nil,
            location: nil,
            images: [],
            likeCount: 42,
            commentCount: 5,
            meetupInterestCount: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        XCTAssertEqual(blogPost.id, "post-1")
        XCTAssertEqual(blogPost.title, "Top 10 Coffee Shops for Studying")
        XCTAssertEqual(blogPost.likeCount, 42)
    }
    
    func testBlogServiceExists() {
        let service = BlogService.shared
        XCTAssertNotNil(service)
    }
}
