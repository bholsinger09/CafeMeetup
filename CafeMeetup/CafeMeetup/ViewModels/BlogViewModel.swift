import Foundation
import Combine

@MainActor
class BlogViewModel: ObservableObject {
    @Published var posts: [BlogPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedPost: BlogPost?
    
    private let blogService: BlogServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(blogService: BlogServiceProtocol = BlogService.shared) {
        self.blogService = blogService
    }
    
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await blogService.fetchPosts(limit: 50)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createPost(title: String, content: String, tags: [String], coffeeShopId: String?, coffeeShopName: String?, meetupDate: Date?, currentUser: User) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let post = BlogPost(
                authorId: currentUser.id,
                authorName: currentUser.fullName,
                authorImageURL: currentUser.profileImageURL,
                title: title,
                content: content,
                tags: tags,
                coffeeShopId: coffeeShopId,
                coffeeShopName: coffeeShopName,
                meetupDate: meetupDate,
                location: currentUser.location
            )
            
            let createdPost = try await blogService.createPost(post)
            posts.insert(createdPost, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updatePost(_ post: BlogPost) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedPost = try await blogService.updatePost(post)
            if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
                posts[index] = updatedPost
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deletePost(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await blogService.deletePost(id: id)
            posts.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func likePost(postId: String, userId: String) async {
        do {
            try await blogService.likePost(postId: postId, userId: userId)
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].likeCount += 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func unlikePost(postId: String, userId: String) async {
        do {
            try await blogService.unlikePost(postId: postId, userId: userId)
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].likeCount = max(0, posts[index].likeCount - 1)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
