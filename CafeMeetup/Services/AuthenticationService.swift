import Foundation

protocol AuthenticationServiceProtocol {
    func signUp(email: String, password: String, user: User) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteAccount() async throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    static let shared = AuthenticationService()
    
    private init() {}
    
    // Mock implementation - replace with Firebase/backend integration
    private var currentUser: User?
    private var mockUsers: [String: (password: String, user: User)] = [:]
    
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
        return stored.user
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
