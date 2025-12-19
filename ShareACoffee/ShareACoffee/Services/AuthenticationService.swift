import Foundation

protocol AuthenticationServiceProtocol {
    func signUp(email: String, password: String, user: User) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signInWithApple(userID: String, email: String, fullName: String?) async throws -> User
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteAccount() async throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    static let shared = AuthenticationService()
    
    private init() {
        // Initialize reviewer demo account
        initializeReviewerAccount()
    }
    
    // Mock implementation - replace with Firebase/backend integration
    private var currentUser: User?
    private var mockUsers: [String: (password: String, user: User)] = [:]
    private let userService = UserService.shared
    
    private func initializeReviewerAccount() {
        // Create demo account for Apple App Review
        let reviewerUser = User(
            id: "reviewer-demo-account",
            email: "reviewer@studybrew.demo",
            fullName: "Sarah Johnson",
            college: "Boise State University",
            state: "Idaho",
            city: "Boise",
            address: nil,
            favoriteCoffee: "Vanilla Latte",
            favoriteCoffeeShop: "The Human Bean",
            bio: "Coffee enthusiast and Boise State student. Love meeting new people over a good cup of coffee!",
            gender: "Female",
            location: Location(latitude: 43.6150, longitude: -116.2023), // Boise, ID
            profileImageURL: nil,
            lastActiveAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Store in auth system
        mockUsers["reviewer@studybrew.demo"] = ("Review2025!", reviewerUser)
        
        // Add to user service so they appear in searches
        userService.addMockUser(reviewerUser)
        
        print("✅ [AuthService] Reviewer demo account initialized: reviewer@studybrew.demo")
    }
    
    func signUp(email: String, password: String, user: User) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Check if user already exists
        if mockUsers[email] != nil {
            throw AuthError.emailAlreadyInUse
        }
        
        // Validate password
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        // Store user
        mockUsers[email] = (password, user)
        currentUser = user
        
        // Also add to UserService so they appear on map
        userService.addMockUser(user)
        print("[AuthService] Registered new user in UserService: \(user.fullName)")
        
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard let stored = mockUsers[email] else {
            throw AuthError.userNotFound
        }
        
        guard stored.password == password else {
            throw AuthError.wrongPassword
        }
        
        currentUser = stored.user
        
        // Update user in UserService
        userService.updateUser(stored.user)
        print("[AuthService] Updated user in UserService on sign in: \(stored.user.fullName)")
        
        return stored.user
    }
    
    func signInWithApple(userID: String, email: String, fullName: String?) async throws -> User {
        print("🔒 [AuthService] signInWithApple called")
        print("🔒 [AuthService] userID: \(userID)")
        print("🔒 [AuthService] email: \(email)")
        print("🔒 [AuthService] fullName: \(fullName ?? "nil")")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Check if user already exists with this Apple ID
        if let stored = mockUsers[email] {
            print("✅ [AuthService] Found existing user for email: \(email)")
            currentUser = stored.user
            return stored.user
        }
        
        print("🆕 [AuthService] Creating new user")
        
        // Create new user with Apple Sign In
        let newUser = User(
            id: userID,
            email: email,
            fullName: fullName ?? "Apple User",
            college: "",
            state: "",
            city: "",
            favoriteCoffee: "",
            favoriteCoffeeShop: "",
            bio: nil,
            location: nil
        )
        
        print("✅ [AuthService] New user created: \(newUser.email)")
        mockUsers[email] = (userID, newUser)
        currentUser = newUser
        
        // Add to UserService
        userService.addMockUser(newUser)
        print("[AuthService] Registered Apple user in UserService: \(newUser.fullName)")
        
        return newUser
    }
    
    func signOut() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)
        currentUser = nil
    }
    
    func getCurrentUser() async throws -> User? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)
        return currentUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let email = currentUser?.email else {
            throw AuthError.userNotFound
        }
        
        guard var stored = mockUsers[email] else {
            throw AuthError.userNotFound
        }
        
        stored.user = user
        mockUsers[email] = stored
        currentUser = user
        
        // Update in UserService
        userService.updateUser(user)
        print("[AuthService] Updated user in UserService: \(user.fullName)")
        
        return user
    }
    
    func deleteAccount() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let email = currentUser?.email else {
            throw AuthError.userNotFound
        }
        
        mockUsers.removeValue(forKey: email)
        currentUser = nil
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case wrongPassword
    case invalidEmail
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .userNotFound:
            return "No account found with this email."
        case .wrongPassword:
            return "Incorrect password."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
