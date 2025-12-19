import XCTest
@testable import ShareACoffee

@MainActor
final class AuthStateManagementTests: XCTestCase {
    
    var authViewModel: AuthenticationViewModel!
    var discoveryViewModel: DiscoveryViewModel!
    var matchViewModel: MatchViewModel!
    var messageViewModel: MessageViewModel!
    var mapViewModel: MapViewModel!
    
    override func setUp() {
        super.setUp()
        authViewModel = AuthenticationViewModel()
        discoveryViewModel = DiscoveryViewModel()
        matchViewModel = MatchViewModel()
        messageViewModel = MessageViewModel()
        mapViewModel = MapViewModel()
    }
    
    override func tearDown() {
        authViewModel = nil
        discoveryViewModel = nil
        matchViewModel = nil
        messageViewModel = nil
        mapViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Sign Out State Reset Tests
    
    func testDiscoveryViewModelResetsOnSignOut() async {
        // Given: ViewModel with data
        let testUser = User(
            id: "test1",
            email: "test@example.com",
            fullName: "Test User",
            college: "Test College",
            state: "CA",
            city: "San Francisco",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Local Cafe"
        )
        
        discoveryViewModel.potentialMatches = [testUser]
        discoveryViewModel.currentUserIndex = 0
        discoveryViewModel.showMatchPopup = true
        discoveryViewModel.matchedUser = testUser
        
        // When: Sign out notification is posted
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async reset
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then: State should be reset
        XCTAssertTrue(discoveryViewModel.potentialMatches.isEmpty, "Potential matches should be cleared")
        XCTAssertEqual(discoveryViewModel.currentUserIndex, 0, "Current user index should be reset")
        XCTAssertFalse(discoveryViewModel.showMatchPopup, "Match popup should be hidden")
        XCTAssertNil(discoveryViewModel.matchedUser, "Matched user should be nil")
        XCTAssertNil(discoveryViewModel.errorMessage, "Error message should be nil")
    }
    
    func testMatchViewModelResetsOnSignOut() async {
        // Given: ViewModel with matches
        let testMatch = Match(
            id: "match1",
            user1Id: "user1",
            user2Id: "user2",
            matchedAt: Date(),
            user1: User(
                id: "user1",
                email: "user1@example.com",
                fullName: "User One",
                college: "College",
                state: "CA",
                city: "SF",
                favoriteCoffee: "Latte",
                favoriteCoffeeShop: "Cafe"
            ),
            user2: User(
                id: "user2",
                email: "user2@example.com",
                fullName: "User Two",
                college: "College",
                state: "CA",
                city: "SF",
                favoriteCoffee: "Cappuccino",
                favoriteCoffeeShop: "Cafe"
            )
        )
        
        matchViewModel.matches = [testMatch]
        
        // When: Sign out notification is posted
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async reset
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: State should be reset
        XCTAssertTrue(matchViewModel.matches.isEmpty, "Matches should be cleared")
        XCTAssertNil(matchViewModel.errorMessage, "Error message should be nil")
    }
    
    func testMessageViewModelResetsOnSignOut() async {
        // Given: ViewModel with messages
        let testMessage = Message(
            id: "msg1",
            senderId: "user1",
            receiverId: "user2",
            content: "Hello",
            timestamp: Date(),
            isRead: false
        )
        
        messageViewModel.messages = [testMessage]
        
        // When: Sign out notification is posted
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async reset
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: State should be reset
        XCTAssertTrue(messageViewModel.messages.isEmpty, "Messages should be cleared")
        XCTAssertNil(messageViewModel.errorMessage, "Error message should be nil")
    }
    
    func testMapViewModelResetsOnSignOut() async {
        // Given: ViewModel with users and location
        let testUser = User(
            id: "user1",
            email: "user1@example.com",
            fullName: "User One",
            college: "College",
            state: "CA",
            city: "SF",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )
        
        mapViewModel.users = [testUser]
        mapViewModel.currentUserLocation = Location(latitude: 37.7749, longitude: -122.4194)
        
        // When: Sign out notification is posted
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async reset
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: State should be reset
        XCTAssertTrue(mapViewModel.users.isEmpty, "Users should be cleared")
        XCTAssertNil(mapViewModel.currentUserLocation, "Current user location should be nil")
        XCTAssertNil(mapViewModel.errorMessage, "Error message should be nil")
    }
    
    // MARK: - Multiple Sign Out Tests
    
    func testMultipleSignOutsDoNotCrash() async {
        // Given: ViewModels with data
        discoveryViewModel.potentialMatches = [User(
            id: "test1",
            email: "test@example.com",
            fullName: "Test",
            college: "College",
            state: "CA",
            city: "SF",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )]
        
        // When: Multiple sign out notifications are posted
        for _ in 0..<5 {
            NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        }
        
        // Wait for async resets
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then: Should not crash and state should be clean
        XCTAssertTrue(discoveryViewModel.potentialMatches.isEmpty)
        XCTAssertTrue(matchViewModel.matches.isEmpty)
        XCTAssertTrue(messageViewModel.messages.isEmpty)
        XCTAssertTrue(mapViewModel.users.isEmpty)
    }
    
    // MARK: - State Isolation Tests
    
    func testViewModelsIndependentlyReset() async {
        // Given: Multiple view models with data
        discoveryViewModel.potentialMatches = [User(
            id: "user1",
            email: "user1@example.com",
            fullName: "User One",
            college: "College",
            state: "CA",
            city: "SF",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )]
        
        matchViewModel.matches = [Match(
            id: "match1",
            user1Id: "user1",
            user2Id: "user2",
            matchedAt: Date(),
            user1: User(
                id: "user1",
                email: "user1@example.com",
                fullName: "User One",
                college: "College",
                state: "CA",
                city: "SF",
                favoriteCoffee: "Latte",
                favoriteCoffeeShop: "Cafe"
            ),
            user2: User(
                id: "user2",
                email: "user2@example.com",
                fullName: "User Two",
                college: "College",
                state: "CA",
                city: "SF",
                favoriteCoffee: "Cappuccino",
                favoriteCoffeeShop: "Cafe"
            )
        )]
        
        // When: Sign out occurs
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async resets
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: All view models should be reset independently
        XCTAssertTrue(discoveryViewModel.potentialMatches.isEmpty)
        XCTAssertTrue(matchViewModel.matches.isEmpty)
        XCTAssertTrue(messageViewModel.messages.isEmpty)
        XCTAssertTrue(mapViewModel.users.isEmpty)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateResetOnSignOut() async {
        // Given: ViewModels in loading state
        discoveryViewModel.isLoading = true
        matchViewModel.isLoading = true
        messageViewModel.isLoading = true
        mapViewModel.isLoading = true
        
        // When: Sign out occurs
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async resets
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: Loading states should be reset
        XCTAssertFalse(discoveryViewModel.isLoading)
        XCTAssertFalse(matchViewModel.isLoading)
        XCTAssertFalse(messageViewModel.isLoading)
        XCTAssertFalse(mapViewModel.isLoading)
    }
    
    // MARK: - Error State Tests
    
    func testErrorStateResetOnSignOut() async {
        // Given: ViewModels with errors
        discoveryViewModel.errorMessage = "Some error"
        matchViewModel.errorMessage = "Some error"
        messageViewModel.errorMessage = "Some error"
        mapViewModel.errorMessage = "Some error"
        
        // When: Sign out occurs
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async resets
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: Error messages should be cleared
        XCTAssertNil(discoveryViewModel.errorMessage)
        XCTAssertNil(matchViewModel.errorMessage)
        XCTAssertNil(messageViewModel.errorMessage)
        XCTAssertNil(mapViewModel.errorMessage)
    }
    
    // MARK: - Performance Tests
    
    func testSignOutResetPerformance() {
        measure {
            // Post sign out notification multiple times
            for _ in 0..<100 {
                NotificationCenter.default.post(name: .userDidSignOut, object: nil)
            }
        }
    }
    
    // MARK: - Memory Tests
    
    func testViewModelsDoNotLeakOnSignOut() async {
        // Given: Fresh view models
        weak var weakDiscovery = discoveryViewModel
        weak var weakMatch = matchViewModel
        weak var weakMessage = messageViewModel
        weak var weakMap = mapViewModel
        
        // When: Sign out occurs
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async resets
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: View models should still exist (not prematurely deallocated)
        XCTAssertNotNil(weakDiscovery)
        XCTAssertNotNil(weakMatch)
        XCTAssertNotNil(weakMessage)
        XCTAssertNotNil(weakMap)
    }
}
