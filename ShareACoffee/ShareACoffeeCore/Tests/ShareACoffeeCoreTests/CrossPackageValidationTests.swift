import XCTest
@testable import ShareACoffeeCore
@testable import ShareACoffeeAuth
@testable import ShareACoffeeSocial
@testable import ShareACoffeeDiscovery
@testable import ShareACoffeeStudy
@testable import ShareACoffeeCoffee
@testable import ShareACoffeeBlog

/// Comprehensive validation tests to catch common build and runtime issues
final class CrossPackageValidationTests: XCTestCase {
    
    // MARK: - Core Type Accessibility Tests
    func testCoreTypesAreAccessible() {
        // Verify all Core models can be instantiated
        let user = User(
            id: "test",
            email: "test@example.com",
            fullName: "Test",
            studyInterests: [],
            academicLevel: "Undergrad"
        )
        XCTAssertNotNil(user)
        
        let location = User.Location(latitude: 0, longitude: 0)
        XCTAssertNotNil(location)
        
        let avatar = Avatar(name: "test")
        XCTAssertNotNil(avatar)
    }
    
    // MARK: - Location Type Consistency
    func testLocationTypeUsageInModels() {
        let location = User.Location(latitude: 37.7749, longitude: -122.4194)
        
        // Test in BlogPost
        let blogPost = BlogPost(
            id: "1",
            authorId: "1",
            authorName: "Author",
            title: "Title",
            content: "Content",
            location: location
        )
        XCTAssertNotNil(blogPost.location)
        
        // Test in CoffeeShop
        let coffeeShop = CoffeeShop(
            id: "1",
            name: "Shop",
            address: "123 St",
            city: "City",
            state: "State",
            zipCode: "12345",
            location: location,
            priceRange: .moderate,
            createdAt: Date()
        )
        XCTAssertNotNil(coffeeShop.location)
    }
    
    // MARK: - Protocol Conformance Tests
    func testBlogPostProtocolConformance() {
        let blogPost = BlogPost(
            id: "1",
            authorId: "1",
            authorName: "Author",
            title: "Title",
            content: "Content"
        )
        
        // Test Identifiable
        XCTAssertEqual(blogPost.id, "1")
        
        // Test Codable - encode
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(blogPost)
        XCTAssertNotNil(encoded)
        
        // Test Equatable
        let same = BlogPost(
            id: "1",
            authorId: "1",
            authorName: "Author",
            title: "Title",
            content: "Content"
        )
        XCTAssertEqual(blogPost, same)
    }
    
    func testCoffeeShopProtocolConformance() {
        let location = User.Location(latitude: 0, longitude: 0)
        let shop = CoffeeShop(
            id: "1",
            name: "Shop",
            address: "123",
            city: "City",
            state: "State",
            zipCode: "12345",
            location: location,
            priceRange: .moderate,
            createdAt: Date()
        )
        
        // Test Identifiable
        XCTAssertEqual(shop.id, "1")
        
        // Test Codable - encode
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(shop)
        XCTAssertNotNil(encoded)
    }
    
    // MARK: - Cross-Package Import Tests
    func testAuthCanAccessCoreTypes() {
        let viewModel = AuthenticationViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    func testSocialCanAccessCoreTypes() {
        let match = Match(
            id: "1",
            userId1: "1",
            userId2: "2",
            matchPercentage: 85.0,
            commonInterests: [],
            createdAt: Date()
        )
        XCTAssertNotNil(match)
    }
    
    func testCoffeeCanAccessCoreTypes() {
        let location = User.Location(latitude: 0, longitude: 0)
        let shop = CoffeeShop(
            id: "1",
            name: "Shop",
            address: "123",
            city: "City",
            state: "State",
            zipCode: "12345",
            location: location,
            priceRange: .moderate,
            createdAt: Date()
        )
        XCTAssertNotNil(shop)
    }
    
    func testBlogCanAccessCoreTypes() {
        let location = User.Location(latitude: 0, longitude: 0)
        let post = BlogPost(
            id: "1",
            authorId: "1",
            authorName: "Author",
            title: "Title",
            content: "Content",
            location: location
        )
        XCTAssertNotNil(post)
    }
    
    // MARK: - Model Initialization Tests
    func testAllModelsCanBeInitialized() {
        // Core
        let user = User(id: "1", email: "a@b.com", fullName: "T", studyInterests: [], academicLevel: "")
        let avatar = Avatar(name: "a")
        let course = Course(id: "1", courseCode: "101", courseName: "Test")
        
        // Auth
        let authVM = AuthenticationViewModel()
        
        // Social
        let match = Match(id: "1", userId1: "1", userId2: "2", matchPercentage: 0, commonInterests: [], createdAt: Date())
        let message = Message(id: "1", senderId: "1", recipientId: "2", content: "Hi", timestamp: Date())
        
        // Discovery
        let rec = StudyBuddyRecommendation(id: "1", recommendedUserId: "1", recommendedUserName: "N", matchScore: 0.5)
        
        // Study
        let session = StudySession(id: "1", hostId: "1", hostName: "N", title: "T", description: "D", subject: "M", startTime: Date(), endTime: Date(), location: "L")
        
        // Coffee
        let location = User.Location(latitude: 0, longitude: 0)
        let shop = CoffeeShop(id: "1", name: "S", address: "A", city: "C", state: "S", zipCode: "Z", location: location, priceRange: .moderate, createdAt: Date())
        
        // Blog
        let post = BlogPost(id: "1", authorId: "1", authorName: "A", title: "T", content: "C")
        
        XCTAssertNotNil(user)
        XCTAssertNotNil(avatar)
        XCTAssertNotNil(course)
        XCTAssertNotNil(authVM)
        XCTAssertNotNil(match)
        XCTAssertNotNil(message)
        XCTAssertNotNil(rec)
        XCTAssertNotNil(session)
        XCTAssertNotNil(shop)
        XCTAssertNotNil(post)
    }
}
