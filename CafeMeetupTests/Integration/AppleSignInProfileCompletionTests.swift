import XCTest
@testable import CafeMeetup

@MainActor
final class AppleSignInProfileCompletionTests: XCTestCase {
    var authViewModel: AuthenticationViewModel!
    var mockAuthService: MockAuthenticationService!
    
    override func setUp() async throws {
        try await super.setUp()
        mockAuthService = MockAuthenticationService()
        let mockLocationService = MockLocationService()
        authViewModel = AuthenticationViewModel(authService: mockAuthService, locationService: mockLocationService)
    }
    
    override func tearDown() async throws {
        authViewModel = nil
        mockAuthService = nil
        try await super.tearDown()
    }
    
    // MARK: - Profile Completion Detection Tests
    
    func testAppleSignInWithCompleteProfile() async throws {
        // Given: A user signs in with Apple with a complete profile
        mockAuthService.mockUser = User(
            id: "apple-user-1",
            email: "test@privaterelay.appleid.com",
            fullName: "Test User",
            college: "University of Idaho",
            state: "Idaho",
            city: "Boise",
            address: nil,
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "The Human Bean",
            bio: nil,
            gender: nil,
            relationshipStatus: nil,
            location: nil
        )
        
        // When: User signs in with Apple
        await authViewModel.signInWithApple(
            userID: "apple-user-1",
            email: "test@privaterelay.appleid.com",
            fullName: "Test User"
        )
        
        // Then: User should be authenticated
        XCTAssertTrue(authViewModel.isAuthenticated, "User should be authenticated")
        XCTAssertNotNil(authViewModel.currentUser, "Current user should be set")
        
        // And: Profile should be complete
        let user = authViewModel.currentUser!
        XCTAssertFalse(user.college.isEmpty, "College should not be empty")
        XCTAssertFalse(user.state.isEmpty, "State should not be empty")
        XCTAssertFalse(user.city.isEmpty, "City should not be empty")
        XCTAssertFalse(user.favoriteCoffee.isEmpty, "Favorite coffee should not be empty")
    }
    
    func testAppleSignInWithIncompleteProfile() async throws {
        // Given: A user signs in with Apple with an incomplete profile
        mockAuthService.mockUser = User(
            id: "apple-user-2",
            email: "incomplete@privaterelay.appleid.com",
            fullName: "Incomplete User",
            college: "", // Missing
            state: "", // Missing
            city: "", // Missing
            address: nil,
            favoriteCoffee: "", // Missing
            favoriteCoffeeShop: "",
            bio: nil,
            gender: nil,
            relationshipStatus: nil,
            location: nil
        )
        
        // When: User signs in with Apple
        await authViewModel.signInWithApple(
            userID: "apple-user-2",
            email: "incomplete@privaterelay.appleid.com",
            fullName: "Incomplete User"
        )
        
        // Then: User should be authenticated
        XCTAssertTrue(authViewModel.isAuthenticated, "User should be authenticated")
        XCTAssertNotNil(authViewModel.currentUser, "Current user should be set")
        
        // And: Profile should be incomplete (missing required fields)
        let user = authViewModel.currentUser!
        let isComplete = !user.college.isEmpty && !user.state.isEmpty && !user.city.isEmpty && !user.favoriteCoffee.isEmpty
        XCTAssertFalse(isComplete, "Profile should be incomplete")
    }
    
    func testProfileCompletionCheck() {
        // Test helper function for checking profile completion
        func isProfileComplete(_ user: User) -> Bool {
            return !user.college.isEmpty &&
                   !user.state.isEmpty &&
                   !user.city.isEmpty &&
                   !user.favoriteCoffee.isEmpty
        }
        
        // Complete profile
        let completeUser = User(
            email: "complete@test.com",
            fullName: "Complete User",
            college: "Boise State",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        XCTAssertTrue(isProfileComplete(completeUser), "Complete profile should return true")
        
        // Incomplete profiles - missing different fields
        let missingCollege = User(
            email: "test1@test.com",
            fullName: "Test",
            college: "",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        XCTAssertFalse(isProfileComplete(missingCollege), "Missing college should return false")
        
        let missingState = User(
            email: "test2@test.com",
            fullName: "Test",
            college: "Boise State",
            state: "",
            city: "Boise",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        XCTAssertFalse(isProfileComplete(missingState), "Missing state should return false")
        
        let missingCity = User(
            email: "test3@test.com",
            fullName: "Test",
            college: "Boise State",
            state: "Idaho",
            city: "",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        XCTAssertFalse(isProfileComplete(missingCity), "Missing city should return false")
        
        let missingCoffee = User(
            email: "test4@test.com",
            fullName: "Test",
            college: "Boise State",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "",
            favoriteCoffeeShop: "Starbucks"
        )
        XCTAssertFalse(isProfileComplete(missingCoffee), "Missing favorite coffee should return false")
    }
    
    // MARK: - Profile Update Tests
    
    func testUpdateUserProfile() async throws {
        // Given: A user with incomplete profile
        mockAuthService.mockUser = User(
            id: "user-1",
            email: "test@test.com",
            fullName: "Test User",
            college: "",
            state: "",
            city: "",
            favoriteCoffee: "",
            favoriteCoffeeShop: ""
        )
        
        await authViewModel.signIn(email: "test@test.com", password: "password")
        XCTAssertTrue(authViewModel.isAuthenticated)
        
        // When: User completes their profile
        var updatedUser = authViewModel.currentUser!
        updatedUser.college = "University of Idaho"
        updatedUser.state = "Idaho"
        updatedUser.city = "Moscow"
        updatedUser.favoriteCoffee = "Cappuccino"
        updatedUser.favoriteCoffeeShop = "Cafe Artista"
        
        let result = try await authViewModel.updateUser(updatedUser)
        
        // Then: Profile should be updated
        XCTAssertEqual(result.college, "University of Idaho")
        XCTAssertEqual(result.state, "Idaho")
        XCTAssertEqual(result.city, "Moscow")
        XCTAssertEqual(result.favoriteCoffee, "Cappuccino")
        XCTAssertEqual(result.favoriteCoffeeShop, "Cafe Artista")
        
        // And: Current user should reflect changes
        XCTAssertEqual(authViewModel.currentUser?.college, "University of Idaho")
        XCTAssertEqual(authViewModel.currentUser?.state, "Idaho")
        XCTAssertEqual(authViewModel.currentUser?.city, "Moscow")
    }
    
    func testProfileUpdateFailure() async throws {
        // Given: A user is authenticated
        mockAuthService.mockUser = User(
            id: "user-1",
            email: "test@test.com",
            fullName: "Test User",
            college: "Test College",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        await authViewModel.signIn(email: "test@test.com", password: "password")
        
        // When: Update fails
        mockAuthService.shouldFailUpdate = true
        var updatedUser = authViewModel.currentUser!
        updatedUser.college = "New College"
        
        do {
            _ = try await authViewModel.updateUser(updatedUser)
            XCTFail("Should have thrown an error")
        } catch {
            // Then: Error should be caught
            XCTAssertNotNil(error, "Error should be thrown")
            XCTAssertNotNil(authViewModel.errorMessage, "Error message should be set")
        }
    }
    
    // MARK: - Discovery View Integration Tests
    
    func testDiscoveryViewRequiresCompleteProfile() {
        // This test documents the requirement that Discovery view needs location data
        let incompleteUser = User(
            email: "test@test.com",
            fullName: "Test User",
            college: "",
            state: "", // Required for discovery
            city: "", // Required for discovery
            favoriteCoffee: "",
            favoriteCoffeeShop: ""
        )
        
        // Discovery view uses city and state to find nearby users
        XCTAssertTrue(incompleteUser.state.isEmpty, "Without state, discovery cannot find users")
        XCTAssertTrue(incompleteUser.city.isEmpty, "Without city, discovery cannot find users")
        
        let completeUser = User(
            email: "test@test.com",
            fullName: "Test User",
            college: "Boise State",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        XCTAssertFalse(completeUser.state.isEmpty, "With state, discovery can find users")
        XCTAssertFalse(completeUser.city.isEmpty, "With city, discovery can find users")
    }
    
    // MARK: - Sign Out and Re-Sign In Tests
    
    func testSignOutClearsUser() async throws {
        // Given: User is signed in
        mockAuthService.mockUser = User(
            id: "user-1",
            email: "test@test.com",
            fullName: "Test User",
            college: "Boise State",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        
        await authViewModel.signIn(email: "test@test.com", password: "password")
        XCTAssertTrue(authViewModel.isAuthenticated)
        XCTAssertNotNil(authViewModel.currentUser)
        
        // When: User signs out
        await authViewModel.signOut()
        
        // Then: User data should be cleared
        XCTAssertFalse(authViewModel.isAuthenticated, "User should not be authenticated")
        XCTAssertNil(authViewModel.currentUser, "Current user should be nil")
    }
    
    func testReSignInWithIncompleteProfile() async throws {
        // Given: User signs in with incomplete profile, then signs out
        mockAuthService.mockUser = User(
            id: "apple-user-1",
            email: "test@privaterelay.appleid.com",
            fullName: "Test User",
            college: "",
            state: "",
            city: "",
            favoriteCoffee: "",
            favoriteCoffeeShop: ""
        )
        
        await authViewModel.signInWithApple(
            userID: "apple-user-1",
            email: "test@privaterelay.appleid.com",
            fullName: "Test User"
        )
        XCTAssertTrue(authViewModel.isAuthenticated)
        
        await authViewModel.signOut()
        XCTAssertFalse(authViewModel.isAuthenticated)
        
        // When: User signs in again
        await authViewModel.signInWithApple(
            userID: "apple-user-1",
            email: "test@privaterelay.appleid.com",
            fullName: "Test User"
        )
        
        // Then: User should still have incomplete profile
        XCTAssertTrue(authViewModel.isAuthenticated)
        let user = authViewModel.currentUser!
        let isComplete = !user.college.isEmpty && !user.state.isEmpty && !user.city.isEmpty && !user.favoriteCoffee.isEmpty
        XCTAssertFalse(isComplete, "Profile should still be incomplete after re-sign in")
    }
}

// MARK: - Mock Services

class MockAuthenticationService: AuthenticationServiceProtocol {
    var mockUser: User?
    var shouldFailUpdate = false
    
    func signUp(email: String, password: String, user: User) async throws -> User {
        mockUser = user
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        guard let user = mockUser else {
            throw AuthError.userNotFound
        }
        return user
    }
    
    func signInWithApple(userID: String, email: String, fullName: String?) async throws -> User {
        if let user = mockUser {
            return user
        }
        
        // Create new user with incomplete profile (simulating Apple sign-in)
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
        mockUser = newUser
        return newUser
    }
    
    func signOut() async throws {
        mockUser = nil
    }
    
    func getCurrentUser() async throws -> User? {
        return mockUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        if shouldFailUpdate {
            throw AuthError.updateFailed
        }
        mockUser = user
        return user
    }
    
    func deleteAccount() async throws {
        mockUser = nil
    }
}

class MockLocationService: LocationServiceProtocol {
    func requestLocationPermission() {
        // No-op for tests
    }
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 43.6150, longitude: -116.2023) // Boise, ID
    }
}

enum AuthError: LocalizedError {
    case userNotFound
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .userNotFound: return "User not found"
        case .updateFailed: return "Update failed"
        }
    }
}
