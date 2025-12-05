import XCTest
@testable import CafeMeetup
import Combine

@MainActor
final class SignOutSignInDebugTests: XCTestCase {
    
    var discoveryViewModel: DiscoveryViewModel!
    var matchViewModel: MatchViewModel!
    var messageViewModel: MessageViewModel!
    var mapViewModel: MapViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()
        
        print("\n" + String(repeating: "=", count: 60))
        print("🧪 TEST SETUP: \(name)")
        print(String(repeating: "=", count: 60))
        
        discoveryViewModel = DiscoveryViewModel()
        matchViewModel = MatchViewModel()
        messageViewModel = MessageViewModel()
        mapViewModel = MapViewModel()
    }
    
    override func tearDown() async throws {
        print("\n" + String(repeating: "-", count: 60))
        print("🧹 TEST TEARDOWN: \(name)")
        print(String(repeating: "-", count: 60) + "\n")
        
        discoveryViewModel = nil
        matchViewModel = nil
        messageViewModel = nil
        mapViewModel = nil
        cancellables = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Discovery ViewModel Tests
    
    func testDiscoveryViewModelInitialization() {
        print("\n📋 Testing DiscoveryViewModel initialization")
        
        XCTAssertNotNil(discoveryViewModel, "DiscoveryViewModel should be initialized")
        XCTAssertTrue(discoveryViewModel.potentialMatches.isEmpty, "Should start with empty matches")
        XCTAssertEqual(discoveryViewModel.currentUserIndex, 0, "Should start at index 0")
        XCTAssertFalse(discoveryViewModel.isLoading, "Should not be loading initially")
        
        print("✅ DiscoveryViewModel initialized correctly")
    }
    
    func testDiscoveryViewModelSignOutNotification() async throws {
        print("\n📋 Testing DiscoveryViewModel sign-out notification handling")
        
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
        
        print("📊 Before notification:")
        print("   - Potential matches: \(discoveryViewModel.potentialMatches.count)")
        print("   - Current index: \(discoveryViewModel.currentUserIndex)")
        print("   - Show popup: \(discoveryViewModel.showMatchPopup)")
        print("   - Matched user: \(discoveryViewModel.matchedUser?.fullName ?? "nil")")
        
        // When: Sign out notification is posted
        print("\n📢 Posting userDidSignOut notification...")
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async reset (notification handling is async)
        print("⏳ Waiting for async reset...")
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        print("\n📊 After notification:")
        print("   - Potential matches: \(discoveryViewModel.potentialMatches.count)")
        print("   - Current index: \(discoveryViewModel.currentUserIndex)")
        print("   - Show popup: \(discoveryViewModel.showMatchPopup)")
        print("   - Matched user: \(discoveryViewModel.matchedUser?.fullName ?? "nil")")
        
        // Then: State should be reset
        XCTAssertTrue(discoveryViewModel.potentialMatches.isEmpty, "Potential matches should be cleared")
        XCTAssertEqual(discoveryViewModel.currentUserIndex, 0, "Index should be reset to 0")
        XCTAssertFalse(discoveryViewModel.showMatchPopup, "Match popup should be hidden")
        XCTAssertNil(discoveryViewModel.matchedUser, "Matched user should be nil")
        
        print("✅ DiscoveryViewModel correctly reset on sign-out")
    }
    
    func testDiscoveryViewModelPersistsThroughMultipleSignOuts() async throws {
        print("\n📋 Testing DiscoveryViewModel persistence through multiple sign-outs")
        
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
        
        for i in 1...3 {
            print("\n🔄 Sign-out cycle \(i):")
            
            // Add data
            discoveryViewModel.potentialMatches = [testUser]
            print("   📝 Added data: \(discoveryViewModel.potentialMatches.count) matches")
            
            // Post sign-out
            print("   📢 Posting sign-out notification")
            NotificationCenter.default.post(name: .userDidSignOut, object: nil)
            
            // Wait
            try await Task.sleep(nanoseconds: 150_000_000)
            
            // Verify reset
            print("   ✓ After reset: \(discoveryViewModel.potentialMatches.count) matches")
            XCTAssertTrue(discoveryViewModel.potentialMatches.isEmpty, "Should be empty after sign-out \(i)")
        }
        
        print("\n✅ DiscoveryViewModel handled multiple sign-outs correctly")
    }
    
    // MARK: - All ViewModels Test
    
    func testAllViewModelsResetOnSignOut() async throws {
        print("\n📋 Testing all ViewModels reset on sign-out")
        
        // Given: All ViewModels with data
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
        
        discoveryViewModel.potentialMatches = [testUser]
        matchViewModel.matches = [Match(
            id: "match1",
            user1Id: "user1",
            user2Id: "user2",
            matchedAt: Date(),
            user1: testUser,
            user2: testUser
        )]
        messageViewModel.messages = [Message(
            id: "msg1",
            senderId: "user1",
            receiverId: "user2",
            content: "Hello",
            timestamp: Date(),
            isRead: false
        )]
        mapViewModel.users = [testUser]
        
        print("📊 Before sign-out:")
        print("   - Discovery matches: \(discoveryViewModel.potentialMatches.count)")
        print("   - Matches: \(matchViewModel.matches.count)")
        print("   - Messages: \(messageViewModel.messages.count)")
        print("   - Map users: \(mapViewModel.users.count)")
        
        // When: Sign out
        print("\n📢 Posting userDidSignOut notification...")
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        print("\n📊 After sign-out:")
        print("   - Discovery matches: \(discoveryViewModel.potentialMatches.count)")
        print("   - Matches: \(matchViewModel.matches.count)")
        print("   - Messages: \(messageViewModel.messages.count)")
        print("   - Map users: \(mapViewModel.users.count)")
        
        // Then: All should be reset
        XCTAssertTrue(discoveryViewModel.potentialMatches.isEmpty, "Discovery should be empty")
        XCTAssertTrue(matchViewModel.matches.isEmpty, "Matches should be empty")
        XCTAssertTrue(messageViewModel.messages.isEmpty, "Messages should be empty")
        XCTAssertTrue(mapViewModel.users.isEmpty, "Map users should be empty")
        
        print("\n✅ All ViewModels reset correctly")
    }
    
    // MARK: - Notification Listener Tests
    
    func testNotificationListenersAreActive() async throws {
        print("\n📋 Testing notification listeners are active")
        
        var discoveryResetCalled = false
        var matchResetCalled = false
        var messageResetCalled = false
        var mapResetCalled = false
        
        // Monitor reset calls by checking state changes
        let initialDiscoveryMatches = discoveryViewModel.potentialMatches.count
        let initialMatches = matchViewModel.matches.count
        let initialMessages = messageViewModel.messages.count
        let initialMapUsers = mapViewModel.users.count
        
        // Add data
        let testUser = User(
            id: "test",
            email: "test@example.com",
            fullName: "Test",
            college: "College",
            state: "CA",
            city: "SF",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )
        
        discoveryViewModel.potentialMatches = [testUser]
        matchViewModel.matches = [Match(
            id: "match1",
            user1Id: "user1",
            user2Id: "user2",
            matchedAt: Date(),
            user1: testUser,
            user2: testUser
        )]
        messageViewModel.messages = [Message(
            id: "msg1",
            senderId: "user1",
            receiverId: "user2",
            content: "Hello",
            timestamp: Date(),
            isRead: false
        )]
        mapViewModel.users = [testUser]
        
        print("📊 Data added to all ViewModels")
        
        // Post notification
        print("📢 Posting userDidSignOut notification...")
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Check if reset occurred
        discoveryResetCalled = discoveryViewModel.potentialMatches.isEmpty
        matchResetCalled = matchViewModel.matches.isEmpty
        messageResetCalled = messageViewModel.messages.isEmpty
        mapResetCalled = mapViewModel.users.isEmpty
        
        print("\n📊 Listener Status:")
        print("   - Discovery listener active: \(discoveryResetCalled)")
        print("   - Match listener active: \(matchResetCalled)")
        print("   - Message listener active: \(messageResetCalled)")
        print("   - Map listener active: \(mapResetCalled)")
        
        XCTAssertTrue(discoveryResetCalled, "Discovery listener should be active")
        XCTAssertTrue(matchResetCalled, "Match listener should be active")
        XCTAssertTrue(messageResetCalled, "Message listener should be active")
        XCTAssertTrue(mapResetCalled, "Map listener should be active")
        
        print("\n✅ All notification listeners are active and working")
    }
    
    // MARK: - Performance Tests
    
    func testSignOutPerformance() {
        print("\n📋 Testing sign-out performance")
        
        measure {
            // Add data and post sign-out 100 times
            for _ in 0..<100 {
                let testUser = User(
                    id: "test",
                    email: "test@example.com",
                    fullName: "Test",
                    college: "College",
                    state: "CA",
                    city: "SF",
                    favoriteCoffee: "Latte",
                    favoriteCoffeeShop: "Cafe"
                )
                discoveryViewModel.potentialMatches = [testUser]
                NotificationCenter.default.post(name: .userDidSignOut, object: nil)
            }
        }
        
        print("✅ Performance test complete")
    }
}
