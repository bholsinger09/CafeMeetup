import Foundation

protocol UserServiceProtocol {
    func fetchUsers(inCity city: String, state: String) async throws -> [User]
    func fetchUser(id: String) async throws -> User
    func searchUsers(query: String) async throws -> [User]
}

class UserService: UserServiceProtocol {
    static let shared = UserService()
    
    private init() {}
    
    // Mock data storage
    private var users: [User] = []
    
    func fetchUsers(inCity city: String, state: String) async throws -> [User] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return users.filter { $0.city.lowercased() == city.lowercased() && $0.state.lowercased() == state.lowercased() }
    }
    
    func fetchUser(id: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let user = users.first(where: { $0.id == id }) else {
            throw UserError.userNotFound
        }
        
        return user
    }
    
    func searchUsers(query: String) async throws -> [User] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000)
        
        let lowercasedQuery = query.lowercased()
        return users.filter {
            $0.fullName.lowercased().contains(lowercasedQuery) ||
            $0.college.lowercased().contains(lowercasedQuery) ||
            $0.city.lowercased().contains(lowercasedQuery)
        }
    }
    
    // Helper method to add mock users for testing
    func addMockUser(_ user: User) {
        users.append(user)
    }
}

// MARK: - User Errors
enum UserError: LocalizedError {
    case userNotFound
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found."
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
