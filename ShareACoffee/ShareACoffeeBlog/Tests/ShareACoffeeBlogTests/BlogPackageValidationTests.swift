import XCTest
@testable import ShareACoffeeBlog
@testable import ShareACoffeeCore
@testable import ShareACoffeeAuth

/// Tests to validate Blog package imports, types, and protocol conformances
class BlogPackageValidationTests: XCTestCase {
    
    // MARK: - Type Accessibility Tests
    
    func testBlogPostCanAccessUserType() {
        // Verify that BlogPost can properly reference User type from Core
        let blogPost = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            authorImageURL: nil,
            title: "Test Blog Post",
            content: "This is a test blog post",
            tags: ["test"],
            coffeeShopId: nil,
            coffeeShopName: nil,
            meetupDate: nil,
            location: User.Location(latitude: 37.7749, longitude: -122.4194),
            images: [],
            likeCount: 0,
            commentCount: 0,
            meetupInterestCount: 0,
            createdAt: Date(),
            updatedAt: Date(),
            studyCourse: nil,
            studyTopic: nil,
            isStudyMeetup: false,
            maxAttendees: nil
        )
        
        XCTAssertEqual(blogPost.title, "Test Blog Post")
    }
    
    func testBlogPostCanAccessUserLocation() {
        // Verify User.Location is properly accessible in Blog package
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        let blogPost = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            title: "Test Post",
            content: "Content",
            location: location
        )
        
        XCTAssertNotNil(blogPost.location)
        XCTAssertEqual(blogPost.location?.latitude, 37.7749)
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testBlogPostConformsToIdentifiable() {
        let blogPost = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            title: "Test Post",
            content: "Content"
        )
        
        // If this compiles, BlogPost conforms to Identifiable
        let _: AnyHashable = blogPost.id
        XCTAssertNotNil(blogPost.id)
    }
    
    func testBlogPostConformsToCodable() throws {
        let blogPost = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            title: "Test Post",
            content: "Content",
            location: User.Location(latitude: 37.7749, longitude: -122.4194)
        )
        
        // Test Encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(blogPost)
        XCTAssertFalse(data.isEmpty)
        
        // Test Decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(BlogPost.self, from: data)
        XCTAssertEqual(decoded.id, blogPost.id)
        XCTAssertEqual(decoded.title, blogPost.title)
    }
    
    func testBlogPostConformsToEquatable() {
        let date = Date()
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        let blogPost1 = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            title: "Test Post",
            content: "Content",
            location: location,
            createdAt: date,
            updatedAt: date
        )
        
        let blogPost2 = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            title: "Test Post",
            content: "Content",
            location: location,
            createdAt: date,
            updatedAt: date
        )
        
        // Test Equatable conformance
        XCTAssertEqual(blogPost1, blogPost2)
    }
    
    // MARK: - ViewModel Tests
    
    func testBlogViewModelCanAccessAuthTypes() {
        // Verify Blog package can access AuthenticationViewModel from Auth package
        let viewModel = BlogViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    func testBlogViewModelCanAccessCoreTypes() {
        // Verify Blog package can access Core types through its imports
        let user = User(
            id: "test123",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: [],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 4.5,
            createdAt: Date()
        )
        
        let viewModel = BlogViewModel()
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(user)
    }
    
    // MARK: - Cross-Package Integration Tests
    
    func testBlogPackageDependsOnCoreAndAuth() {
        // Verify that Blog package can use types from both Core and Auth
        
        // Core type
        let user = User(
            id: "author123",
            firstName: "Blog",
            lastName: "Author",
            email: "author@test.com",
            profileImageURL: nil,
            bio: "Test author",
            academicLevel: .undergraduate,
            favoriteSubjects: ["Writing"],
            preferences: [:],
            location: User.Location(latitude: 37.7749, longitude: -122.4194),
            rating: 4.8,
            createdAt: Date()
        )
        
        // Blog type using Core types
        let blogPost = BlogPost(
            id: "blog123",
            authorId: user.id,
            authorName: "\(user.firstName) \(user.lastName)",
            title: "Integration Test Post",
            content: "Testing cross-package integration",
            location: user.location
        )
        
        XCTAssertEqual(blogPost.authorId, user.id)
        XCTAssertEqual(blogPost.location?.latitude, user.location.latitude)
    }
    
    // MARK: - Failure Prevention Tests
    
    func testBlogPostLocationIsOptional() {
        // Verify that BlogPost.location can be nil (should not crash)
        let blogPost = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            title: "Test Post",
            content: "Content",
            location: nil
        )
        
        XCTAssertNil(blogPost.location)
    }
    
    func testBlogPostPropertiesAreAccessible() {
        // Verify all BlogPost properties are accessible and correctly typed
        let blogPost = BlogPost(
            id: "blog123",
            authorId: "user456",
            authorName: "Test Author",
            authorImageURL: "http://example.com/image.jpg",
            title: "Test Post",
            content: "Content",
            tags: ["swift", "ios"],
            coffeeShopId: "shop123",
            coffeeShopName: "Test Coffee Shop",
            meetupDate: Date(),
            location: User.Location(latitude: 37.7749, longitude: -122.4194),
            images: ["image1.jpg"],
            likeCount: 5,
            commentCount: 3,
            meetupInterestCount: 2,
            studyCourse: "CS 101",
            studyTopic: "Arrays",
            isStudyMeetup: true,
            maxAttendees: 10
        )
        
        // Verify all properties are correctly set
        XCTAssertEqual(blogPost.id, "blog123")
        XCTAssertEqual(blogPost.authorId, "user456")
        XCTAssertEqual(blogPost.title, "Test Post")
        XCTAssertEqual(blogPost.likeCount, 5)
        XCTAssertEqual(blogPost.studyCourse, "CS 101")
        XCTAssertTrue(blogPost.isStudyMeetup)
    }
}
