import XCTest
@testable import CafeMeetup

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    
    var viewModel: AuthenticationViewModel!
    var mockAuthService: MockAuthenticationService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        viewModel = AuthenticationViewModel(authService: mockAuthService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testSignUpSuccess() async {
        await viewModel.signUp(
            email: "test@example.com",
            password: "password123",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.currentUser?.email, "test@example.com")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSignUpWithWeakPassword() async {
        mockAuthService.shouldFail = true
        mockAuthService.errorToThrow = AuthError.weakPassword
        
        await viewModel.signUp(
            email: "test@example.com",
            password: "123",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.currentUser)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testSignInSuccess() async {
        // First sign up
        await viewModel.signUp(
            email: "test@example.com",
            password: "password123",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        // Sign out
        await viewModel.signOut()
        XCTAssertFalse(viewModel.isAuthenticated)
        
        // Sign in again
        await viewModel.signIn(email: "test@example.com", password: "password123")
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.currentUser?.email, "test@example.com")
    }
    
    func testSignInWithWrongPassword() async {
        mockAuthService.shouldFail = true
        mockAuthService.errorToThrow = AuthError.wrongPassword
        
        await viewModel.signIn(email: "test@example.com", password: "wrongpassword")
        
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.currentUser)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testSignOut() async {
        // Sign up first
        await viewModel.signUp(
            email: "test@example.com",
            password: "password123",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        XCTAssertTrue(viewModel.isAuthenticated)
        
        // Sign out
        await viewModel.signOut()
        
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.currentUser)
    }
    
    func testUpdateProfile() async {
        // Sign up first
        await viewModel.signUp(
            email: "test@example.com",
            password: "password123",
            fullName: "John Doe",
            college: "Test University",
            state: "California",
            city: "Los Angeles",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        // Update profile
        await viewModel.updateProfile(
            fullName: "Jane Doe",
            college: "New University",
            state: "Texas",
            city: "Austin",
            favoriteCoffee: "Cappuccino",
            favoriteCoffeeShop: "Local Café",
            bio: "Coffee enthusiast"
        )
        
        XCTAssertEqual(viewModel.currentUser?.fullName, "Jane Doe")
        XCTAssertEqual(viewModel.currentUser?.college, "New University")
        XCTAssertEqual(viewModel.currentUser?.state, "Texas")
        XCTAssertEqual(viewModel.currentUser?.city, "Austin")
        XCTAssertEqual(viewModel.currentUser?.favoriteCoffee, "Cappuccino")
        XCTAssertEqual(viewModel.currentUser?.favoriteCoffeeShop, "Local Café")
        XCTAssertEqual(viewModel.currentUser?.bio, "Coffee enthusiast")
    }
}

// MARK: - Mock Authentication Service
class MockAuthenticationService: AuthenticationServiceProtocol {
    var shouldFail = false
    var errorToThrow: Error = AuthError.unknown
    private var currentUser: User?
    private var users: [String: (password: String, user: User)] = [:]
    
    func signUp(email: String, password: String, user: User) async throws -> User {
        if shouldFail {
            throw errorToThrow
        }
        
        users[email] = (password, user)
        currentUser = user
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        if shouldFail {
            throw errorToThrow
        }
        
        guard let stored = users[email] else {
            throw AuthError.userNotFound
        }
        
        guard stored.password == password else {
            throw AuthError.wrongPassword
        }
        
        currentUser = stored.user
        return stored.user
    }
    
    func signOut() async throws {
        if shouldFail {
            throw errorToThrow
        }
        currentUser = nil
    }
    
    func getCurrentUser() async throws -> User? {
        if shouldFail {
            throw errorToThrow
        }
        return currentUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        if shouldFail {
            throw errorToThrow
        }
        
        guard let email = currentUser?.email else {
            throw AuthError.userNotFound
        }
        
        guard var stored = users[email] else {
            throw AuthError.userNotFound
        }
        
        stored.user = user
        users[email] = stored
        currentUser = user
        
        return user
    }
    
    func deleteAccount() async throws {
        if shouldFail {
            throw errorToThrow
        }
        
        guard let email = currentUser?.email else {
            throw AuthError.userNotFound
        }
        
        users.removeValue(forKey: email)
        currentUser = nil
    }
}
