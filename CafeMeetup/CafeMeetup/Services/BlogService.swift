import Foundation

protocol BlogServiceProtocol {
    func fetchPosts(limit: Int) async throws -> [BlogPost]
    func fetchPost(id: String) async throws -> BlogPost
    func createPost(_ post: BlogPost) async throws -> BlogPost
    func updatePost(_ post: BlogPost) async throws -> BlogPost
    func deletePost(id: String) async throws
    func likePost(postId: String, userId: String) async throws
    func unlikePost(postId: String, userId: String) async throws
    func fetchComments(postId: String) async throws -> [Comment]
    func addComment(_ comment: Comment) async throws -> Comment
    func deleteComment(id: String) async throws
}

class BlogService: BlogServiceProtocol {
    static let shared = BlogService()
    
    private init() {}
    
    // Mock data storage
    private var posts: [BlogPost] = []
    private var comments: [Comment] = []
    private var likes: [Like] = []
    
    func fetchPosts(limit: Int = 50) async throws -> [BlogPost] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Return sorted by most recent
        return Array(posts.sorted { $0.createdAt > $1.createdAt }.prefix(limit))
    }
    
    func fetchPost(id: String) async throws -> BlogPost {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let post = posts.first(where: { $0.id == id }) else {
            throw BlogError.postNotFound
        }
        
        return post
    }
    
    func createPost(_ post: BlogPost) async throws -> BlogPost {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        posts.append(post)
        return post
    }
    
    func updatePost(_ post: BlogPost) async throws -> BlogPost {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000)
        
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
            throw BlogError.postNotFound
        }
        
        posts[index] = post
        return post
    }
    
    func deletePost(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let index = posts.firstIndex(where: { $0.id == id }) else {
            throw BlogError.postNotFound
        }
        
        posts.remove(at: index)
        
        // Remove associated comments and likes
        comments.removeAll { $0.postId == id }
        likes.removeAll { $0.postId == id }
    }
    
    func likePost(postId: String, userId: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let index = posts.firstIndex(where: { $0.id == postId }) else {
            throw BlogError.postNotFound
        }
        
        // Check if already liked
        if likes.contains(where: { $0.postId == postId && $0.userId == userId }) {
            return
        }
        
        let like = Like(postId: postId, userId: userId)
        likes.append(like)
        posts[index].likeCount += 1
    }
    
    func unlikePost(postId: String, userId: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let index = posts.firstIndex(where: { $0.id == postId }) else {
            throw BlogError.postNotFound
        }
        
        likes.removeAll { $0.postId == postId && $0.userId == userId }
        posts[index].likeCount = max(0, posts[index].likeCount - 1)
    }
    
    func fetchComments(postId: String) async throws -> [Comment] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return comments.filter { $0.postId == postId }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func addComment(_ comment: Comment) async throws -> Comment {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000)
        
        guard let index = posts.firstIndex(where: { $0.id == comment.postId }) else {
            throw BlogError.postNotFound
        }
        
        comments.append(comment)
        posts[index].commentCount += 1
        
        return comment
    }
    
    func deleteComment(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let comment = comments.first(where: { $0.id == id }) else {
            throw BlogError.commentNotFound
        }
        
        comments.removeAll { $0.id == id }
        
        if let index = posts.firstIndex(where: { $0.id == comment.postId }) {
            posts[index].commentCount = max(0, posts[index].commentCount - 1)
        }
    }
}

// MARK: - Blog Errors
enum BlogError: LocalizedError {
    case postNotFound
    case commentNotFound
    case networkError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .postNotFound:
            return "Post not found."
        case .commentNotFound:
            return "Comment not found."
        case .networkError:
            return "Network error. Please check your connection."
        case .unauthorized:
            return "You don't have permission to perform this action."
        }
    }
}
