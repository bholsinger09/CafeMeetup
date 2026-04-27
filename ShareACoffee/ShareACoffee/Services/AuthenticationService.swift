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
    nonisolated(unsafe) static let shared = AuthenticationService()
    
    private init() {
        // Initialize reviewer demo account
        initializeReviewerAccount()
        // Initialize additional sample users for demonstration
        initializeSampleUsers()
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
            updatedAt: Date(),
            isTestUser: true  // Mark as sample profile for transparency
        )
        
        // Store in auth system
        mockUsers["reviewer@studybrew.demo"] = ("Review2025!", reviewerUser)
        
        // Add to user service so they appear in searches
        userService.addMockUser(reviewerUser)
        
        print("✅ [AuthService] Reviewer demo account initialized: reviewer@studybrew.demo")
    }
    
    private func initializeSampleUsers() {
        // Create additional sample users for diversity in recommendations
        // All marked as test users for transparency
        
        let sampleUsers: [User] = [
            User(
                id: "sample-user-1",
                email: "demo1@studybrew.demo",
                fullName: "Alex Chen",
                college: "Boise State University",
                state: "Idaho",
                city: "Boise",
                address: nil,
                favoriteCoffee: "Espresso",
                favoriteCoffeeShop: "Starbucks",
                bio: "CS major passionate about AI and machine learning.",
                gender: "Male",
                location: Location(latitude: 43.6187, longitude: -116.2146),
                profileImageURL: nil,
                lastActiveAt: Date(),
                major: "Computer Science",
                graduationYear: 2026,
                studyHoursThisWeek: 15,
                totalStudySessions: 42,
                studyStreak: 7,
                isTestUser: true
            ),
            User(
                id: "sample-user-2",
                email: "demo2@studybrew.demo",
                fullName: "Emma Davis",
                college: "Boise State University",
                state: "Idaho",
                city: "Boise",
                address: nil,
                favoriteCoffee: "Caramel Macchiato",
                favoriteCoffeeShop: "Dutch Bros",
                bio: "Biology student who loves studying at cozy coffee shops.",
                gender: "Female",
                location: Location(latitude: 43.6202, longitude: -116.2034),
                profileImageURL: nil,
                lastActiveAt: Date(),
                major: "Biology",
                graduationYear: 2025,
                isTutor: true,
                tutorSubjects: ["Biology", "Chemistry"],
                studyHoursThisWeek: 20,
                totalStudySessions: 67,
                studyStreak: 12,
                isTestUser: true
            ),
            User(
                id: "sample-user-3",
                email: "demo3@studybrew.demo",
                fullName: "Michael Rodriguez",
                college: "Boise State University",
                state: "Idaho",
                city: "Boise",
                address: nil,
                favoriteCoffee: "Cold Brew",
                favoriteCoffeeShop: "The Human Bean",
                bio: "Engineering student. Always down for a study session!",
                gender: "Male",
                location: Location(latitude: 43.6125, longitude: -116.1985),
                profileImageURL: nil,
                lastActiveAt: Date(),
                major: "Mechanical Engineering",
                graduationYear: 2027,
                studyHoursThisWeek: 18,
                totalStudySessions: 28,
                studyStreak: 5,
                isTestUser: true
            )
        ]
        
        for user in sampleUsers {
            userService.addMockUser(user)
        }
        
        print("✅ [AuthService] Initialized \(sampleUsers.count) sample users for demonstration")
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
        print("🔍 [AuthService] updateUser called for user: \(user.email)")
        print("🔍 [AuthService] User data - Country: '\(user.country)', State: '\(user.state)', City: '\(user.city)'")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let email = currentUser?.email else {
            print("❌ [AuthService] No current user email")
            throw AuthError.userNotFound
        }
        
        guard var stored = mockUsers[email] else {
            print("❌ [AuthService] User not found in mockUsers for email: \(email)")
            throw AuthError.userNotFound
        }
        
        print("🔍 [AuthService] Updating stored user...")
        stored.user = user
        mockUsers[email] = stored
        currentUser = user
        
        // Update in UserService
        userService.updateUser(user)
        print("✅ [AuthService] Updated user in UserService: \(user.fullName)")
        print("✅ [AuthService] Returning updated user - Country: '\(user.country)', State: '\(user.state)', City: '\(user.city)'")
        
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
