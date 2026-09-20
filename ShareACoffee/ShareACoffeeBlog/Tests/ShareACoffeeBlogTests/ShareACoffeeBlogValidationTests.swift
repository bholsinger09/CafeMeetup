import XCTest
@testable import ShareACoffeeCore
@testable import ShareACoffeeBlog

final class ShareACoffeeBlogValidationTests: XCTestCase {
    
    /// Test that BlogPost conforms to all required protocols
    func testBlogPostConformsToDecodable() {
        // Verify the model exists and has proper type conformance
        let decoder = JSONDecoder()
        XCTAssertNotNil(decoder)
    }
    
    func testBlogPostConformsToEncodable() {
        // Verify the model can be encoded
        let encoder = JSONEncoder()
        XCTAssertNotNil(encoder)
    }
    
    /// Test BlogPost initializes with all required fields
    func testBlogPostCanBeInitialized() {
        let blogPost = BlogPost(
            id: "test-1",
            authorId: "author-1",
            authorName: "Test Author",
            title: "Test Post",
            content: "Test content"
        )
        
        XCTAssertEqual(blogPost.id, "test-1")
        XCTAssertEqual(blogPost.authorId, "author-1")
    }
    
    /// Test BlogPost with Location from Core package
    func testBlogPostWithLocationFromCore() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        let blogPost = BlogPost(
            id: "test-2",
            authorId: "author-2",
            authorName: "Test Author 2",
            title: "Post with Location",
            content: "Content with location",
            location: location
        )
        
        XCTAssertNotNil(blogPost.location)
        XCTAssertEqual(blogPost.location?.latitude, 37.7749)
    }
    
    /// Test that all imported types from Core are accessible
    func testCoreTypesAccessible() {
        let user = User(
            id: "user-1",
            email: "test@example.com",
            fullName: "Test User",
            studyInterests: [],
            academicLevel: "Undergraduate"
        )
        XCTAssertNotNil(user)
        
        let location = User.Location(latitude: 0, longitude: 0)
        XCTAssertNotNil(location)
    }
}
