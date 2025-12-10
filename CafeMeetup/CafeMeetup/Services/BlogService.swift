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
    func addMeetupInterest(_ interest: MeetupInterest) async throws -> MeetupInterest
    func removeMeetupInterest(postId: String, userId: String) async throws
    func fetchMeetupInterests(postId: String) async throws -> [MeetupInterest]
}

class BlogService: BlogServiceProtocol {
    static let shared = BlogService()
    
    private init() {
        setupMockData()
    }
    
    // Mock data storage
    private var posts: [BlogPost] = []
    private var comments: [Comment] = []
    private var likes: [Like] = []
    private var meetupInterests: [MeetupInterest] = []
    
    private func setupMockData() {
        // Add mock study meetup posts
        let post1 = BlogPost(
            authorId: "user1",
            authorName: "Sarah Johnson",
            authorImageURL: nil,
            title: "CS 101 Midterm Study Group",
            content: "Looking for a few people to review Chapters 1-5 for the upcoming midterm. We can go over algorithms, data structures, and practice problems together. Great opportunity to clarify concepts and share study tips!",
            tags: ["Study Meetup", "Exam Prep", "CS 101"],
            coffeeShopId: nil,
            coffeeShopName: "Central Perk Café",
            meetupDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            location: Location(latitude: 43.6150, longitude: -116.2023),
            studyCourse: "CS 101",
            studyTopic: "Chapters 1-5 Review",
            isStudyMeetup: true,
            maxAttendees: 6
        )
        
        let post2 = BlogPost(
            authorId: "user2",
            authorName: "Mike Chen",
            authorImageURL: nil,
            title: "MATH 250 Homework Help Session",
            content: "Having trouble with integration techniques? Let's work through the problem set together! I've got some good resources and we can help each other understand the trickier problems. Calculus doesn't have to be painful when you have a study group!",
            tags: ["Study Meetup", "Tutoring", "MATH 250"],
            coffeeShopId: nil,
            coffeeShopName: "Bean There Coffee",
            meetupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            location: Location(latitude: 43.6150, longitude: -116.2023),
            studyCourse: "MATH 250",
            studyTopic: "Integration Techniques",
            isStudyMeetup: true,
            maxAttendees: 4
        )
        
        let post3 = BlogPost(
            authorId: "user3",
            authorName: "Emily Rodriguez",
            authorImageURL: nil,
            title: "Final Project Collaboration - CHEM 110",
            content: "Need 2-3 more people for our chemistry lab project. We're working on the organic compounds analysis and could use different perspectives. Meeting to divide tasks and plan our presentation approach.",
            tags: ["Study Meetup", "Project Collaboration", "CHEM 110"],
            coffeeShopId: nil,
            coffeeShopName: "The Grind",
            meetupDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            location: Location(latitude: 43.6150, longitude: -116.2023),
            studyCourse: "CHEM 110",
            studyTopic: "Lab Project Planning",
            isStudyMeetup: true,
            maxAttendees: 5
        )
        
        posts = [post1, post2, post3]
    }
    
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
    
    func addMeetupInterest(_ interest: MeetupInterest) async throws -> MeetupInterest {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let index = posts.firstIndex(where: { $0.id == interest.postId }) else {
            throw BlogError.postNotFound
        }
        
        // Check if already interested
        if meetupInterests.contains(where: { $0.postId == interest.postId && $0.userId == interest.userId }) {
            return interest
        }
        
        meetupInterests.append(interest)
        posts[index].meetupInterestCount += 1
        
        return interest
    }
    
    func removeMeetupInterest(postId: String, userId: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let index = posts.firstIndex(where: { $0.id == postId }) else {
            throw BlogError.postNotFound
        }
        
        meetupInterests.removeAll { $0.postId == postId && $0.userId == userId }
        posts[index].meetupInterestCount = max(0, posts[index].meetupInterestCount - 1)
    }
    
    func fetchMeetupInterests(postId: String) async throws -> [MeetupInterest] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return meetupInterests.filter { $0.postId == postId }.sorted { $0.createdAt > $1.createdAt }
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
