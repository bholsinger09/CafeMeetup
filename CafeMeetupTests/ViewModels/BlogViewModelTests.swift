import XCTest
@testable import CafeMeetup

@MainActor
final class BlogViewModelTests: XCTestCase {
    
    var viewModel: BlogViewModel!
    var mockBlogService: MockBlogService!
    var testUser: User!
    
    override func setUp() {
        super.setUp()
        mockBlogService = MockBlogService()
        viewModel = BlogViewModel(blogService: mockBlogService)
        
        testUser = User(
            id: "user123",
            email: "test@example.com",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockBlogService = nil
        testUser = nil
        super.tearDown()
    }
    
    func testFetchPosts() async {
        let post1 = BlogPost(
            authorId: "user1",
            authorName: "John Doe",
            title: "Coffee Meetup",
            content: "Let's meet!"
        )
        
        let post2 = BlogPost(
            authorId: "user2",
            authorName: "Jane Smith",
            title: "Study Session",
            content: "Anyone want to study?"
        )
        
        mockBlogService.mockPosts = [post1, post2]
        
        await viewModel.fetchPosts()
        
        XCTAssertEqual(viewModel.posts.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testCreatePost() async {
        await viewModel.createPost(
            title: "New Meetup",
            content: "Join us for coffee!",
            tags: ["Meetup", "Coffee"],
            coffeeShopId: nil,
            coffeeShopName: "Starbucks",
            meetupDate: Date(),
            currentUser: testUser
        )
        
        XCTAssertEqual(viewModel.posts.count, 1)
        XCTAssertEqual(viewModel.posts.first?.title, "New Meetup")
        XCTAssertEqual(viewModel.posts.first?.content, "Join us for coffee!")
        XCTAssertEqual(viewModel.posts.first?.authorId, testUser.id)
    }
    
    func testLikePost() async {
        let post = BlogPost(
            id: "post123",
            authorId: "user1",
            authorName: "John Doe",
            title: "Test Post",
            content: "Test content"
        )
        
        mockBlogService.mockPosts = [post]
        await viewModel.fetchPosts()
        
        await viewModel.likePost(postId: "post123", userId: testUser.id)
        
        XCTAssertEqual(viewModel.posts.first?.likeCount, 1)
    }
    
    func testUnlikePost() async {
        var post = BlogPost(
            id: "post123",
            authorId: "user1",
            authorName: "John Doe",
            title: "Test Post",
            content: "Test content"
        )
        post.likeCount = 5
        
        mockBlogService.mockPosts = [post]
        await viewModel.fetchPosts()
        
        await viewModel.unlikePost(postId: "post123", userId: testUser.id)
        
        XCTAssertEqual(viewModel.posts.first?.likeCount, 4)
    }
    
    func testDeletePost() async {
        let post = BlogPost(
            id: "post123",
            authorId: testUser.id,
            authorName: testUser.fullName,
            title: "Test Post",
            content: "Test content"
        )
        
        mockBlogService.mockPosts = [post]
        await viewModel.fetchPosts()
        
        XCTAssertEqual(viewModel.posts.count, 1)
        
        await viewModel.deletePost(id: "post123")
        
        XCTAssertEqual(viewModel.posts.count, 0)
    }
}

// MARK: - Mock Blog Service
class MockBlogService: BlogServiceProtocol {
    var mockPosts: [BlogPost] = []
    var mockComments: [Comment] = []
    var shouldFail = false
    
    func fetchPosts(limit: Int) async throws -> [BlogPost] {
        if shouldFail {
            throw BlogError.networkError
        }
        return mockPosts
    }
    
    func fetchPost(id: String) async throws -> BlogPost {
        if shouldFail {
            throw BlogError.networkError
        }
        guard let post = mockPosts.first(where: { $0.id == id }) else {
            throw BlogError.postNotFound
        }
        return post
    }
    
    func createPost(_ post: BlogPost) async throws -> BlogPost {
        if shouldFail {
            throw BlogError.networkError
        }
        mockPosts.append(post)
        return post
    }
    
    func updatePost(_ post: BlogPost) async throws -> BlogPost {
        if shouldFail {
            throw BlogError.networkError
        }
        if let index = mockPosts.firstIndex(where: { $0.id == post.id }) {
            mockPosts[index] = post
        }
        return post
    }
    
    func deletePost(id: String) async throws {
        if shouldFail {
            throw BlogError.networkError
        }
        mockPosts.removeAll { $0.id == id }
    }
    
    func likePost(postId: String, userId: String) async throws {
        if shouldFail {
            throw BlogError.networkError
        }
        if let index = mockPosts.firstIndex(where: { $0.id == postId }) {
            mockPosts[index].likeCount += 1
        }
    }
    
    func unlikePost(postId: String, userId: String) async throws {
        if shouldFail {
            throw BlogError.networkError
        }
        if let index = mockPosts.firstIndex(where: { $0.id == postId }) {
            mockPosts[index].likeCount = max(0, mockPosts[index].likeCount - 1)
        }
    }
    
    func fetchComments(postId: String) async throws -> [Comment] {
        if shouldFail {
            throw BlogError.networkError
        }
        return mockComments.filter { $0.postId == postId }
    }
    
    func addComment(_ comment: Comment) async throws -> Comment {
        if shouldFail {
            throw BlogError.networkError
        }
        mockComments.append(comment)
        return comment
    }
    
    func deleteComment(id: String) async throws {
        if shouldFail {
            throw BlogError.networkError
        }
        mockComments.removeAll { $0.id == id }
    }
}
