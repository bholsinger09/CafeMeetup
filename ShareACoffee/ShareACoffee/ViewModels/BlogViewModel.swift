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
}
