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
    
    convenience init() {
        self.init(blogService: BlogService.shared)
    }
    
    init(blogService: BlogServiceProtocol) {
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
    
    func createPost(title: String, content: String, tags: [String], coffeeShopId: String?, coffeeShopName: String?, meetupDate: Date?, currentUser: User, studyCourse: String? = nil, studyTopic: String? = nil, isStudyMeetup: Bool = false, maxAttendees: Int? = nil) async {
        print("📝 [BlogViewModel] createPost called")
        print("📝 [BlogViewModel] Title: '\(title)'")
        print("📝 [BlogViewModel] Content: '\(content)'")
        print("📝 [BlogViewModel] Tags: \(tags)")
        print("📝 [BlogViewModel] Study Meetup: \(isStudyMeetup)")
        if isStudyMeetup {
            print("📝 [BlogViewModel] Course: \(studyCourse ?? "N/A"), Topic: \(studyTopic ?? "N/A"), Max: \(maxAttendees ?? 0)")
        }
        
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
                location: currentUser.location,
                studyCourse: studyCourse,
                studyTopic: studyTopic,
                isStudyMeetup: isStudyMeetup,
                maxAttendees: maxAttendees
            )
            
            print("📝 [BlogViewModel] Post object created: \(post.id)")
            print("📝 [BlogViewModel] Calling blogService.createPost...")
            
            let createdPost = try await blogService.createPost(post)
            
            print("✅ [BlogViewModel] Post created successfully: \(createdPost.id)")
            
            posts.insert(createdPost, at: 0)
            
            print("✅ [BlogViewModel] Post added to posts array. Total posts: \(posts.count)")
        } catch {
            print("❌ [BlogViewModel] Error creating post: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        print("📝 [BlogViewModel] isLoading set to false")
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
    
    func addComment(postId: String, content: String, currentUser: User) async {
        do {
            let comment = Comment(
                postId: postId,
                authorId: currentUser.id,
                authorName: currentUser.fullName,
                authorImageURL: currentUser.profileImageURL,
                content: content
            )
            _ = try await blogService.addComment(comment)
            
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].commentCount += 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchComments(postId: String) async -> [Comment] {
        do {
            return try await blogService.fetchComments(postId: postId)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
    
    func addMeetupInterest(postId: String, currentUser: User) async {
        do {
            let interest = MeetupInterest(
                postId: postId,
                userId: currentUser.id,
                userName: currentUser.fullName,
                userEmail: currentUser.email
            )
            _ = try await blogService.addMeetupInterest(interest)
            
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].meetupInterestCount += 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func removeMeetupInterest(postId: String, userId: String) async {
        do {
            try await blogService.removeMeetupInterest(postId: postId, userId: userId)
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].meetupInterestCount = max(0, posts[index].meetupInterestCount - 1)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchMeetupInterests(postId: String) async -> [MeetupInterest] {
        do {
            return try await blogService.fetchMeetupInterests(postId: postId)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
}
