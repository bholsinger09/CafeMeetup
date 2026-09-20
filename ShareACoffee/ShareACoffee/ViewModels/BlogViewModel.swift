import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeBlog

/// ViewModel for blog feed and post management
@MainActor
public class BlogViewModel: ObservableObject {
    @Published public var posts: [BlogPost] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var comments: [Comment] = []
    @Published public var meetupInterests: [MeetupInterest] = []
    
    public init() {
        loadPosts()
    }
    
    public func loadPosts() {
        isLoading = true
        // Mock data - in production would load from service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
    
    public func fetchComments(for postId: String) {
        // Fetch comments for post
    }
    
    public func addComment(_ content: String, to postId: String) {
        // Add comment to post
    }
    
    public func fetchMeetupInterests(for postId: String) {
        // Fetch meetup interests for post
    }
}

