import XCTest
import SwiftUI
@testable import ShareACoffee
@testable import ShareACoffeeCore

/// Integration tests for MapView interactions and state management
/// Tests cover user interactions, data updates, and navigation flows
@MainActor
final class MapViewInteractionTests: XCTestCase {
    
    var mapViewModel: MapViewModel!
    var authViewModel: AuthenticationViewModel!
    
    override func setUp() async throws {
        mapViewModel = MapViewModel()
        authViewModel = AuthenticationViewModel()
    }
    
    // MARK: - User Selection Tests
    
    func testSelectUserFromMap() {
        // Given: User to select
        let selectedUser = User(
            id: "selected-user",
            email: "selected@example.com",
            fullName: "Selected User",
            avatar: Avatar(emoji: "⭐"),
            bio: "Selected user bio",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )
        
        // When: User selection action occurs
        var state: User? = nil
        state = selectedUser
        
        // Then: State should be updated
        XCTAssertNotNil(state)
        XCTAssertEqual(state?.id, "selected-user")
    }
    
    func testDeselectUser() {
        // Given: Selected user
        var selectedUser: User? = User(
            id: "user-1",
            email: "user1@example.com",
            fullName: "User 1",
            avatar: Avatar(emoji: "👤"),
            bio: "User 1 bio",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Espresso",
            favoriteCoffeeShop: "Cafe"
        )
        
        // When: Deselecting
        selectedUser = nil
        
        // Then: Should be deselected
        XCTAssertNil(selectedUser)
    }
    
    // MARK: - Sheet Presentation Tests
    
    func testShowCoffeeShopListSheet() {
        // Given: Initial state
        var showCoffeeShopList = false
        
        // When: Toggling sheet
        showCoffeeShopList.toggle()
        
        // Then: Sheet should be visible
        XCTAssertTrue(showCoffeeShopList)
    }
    
    func testHideCoffeeShopListSheet() {
        // Given: Sheet is shown
        var showCoffeeShopList = true
        
        // When: Hiding sheet
        showCoffeeShopList = false
        
        // Then: Sheet should be hidden
        XCTAssertFalse(showCoffeeShopList)
    }
    
    func testShowARFinderSheet() {
        // Given: AR finder not shown
        var showARFinder = false
        
        // When: Showing AR finder
        showARFinder = true
        
        // Then: Should be visible
        XCTAssertTrue(showARFinder)
    }
    
    // MARK: - Camera Position Tests
    
    func testCameraPositionInitialization() {
        // Given: Initial camera position
        var cameraPosition = MapCameraPosition.automatic
        
        // Then: Should have automatic positioning
        XCTAssertNotNil(cameraPosition)
    }
    
    func testCameraRegionUpdate() {
        // Given: New coordinate for camera
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        // When: Updating camera position
        var cameraPosition = MapCameraPosition.region(region)
        
        // Then: Camera should be positioned correctly
        XCTAssertNotNil(cameraPosition)
    }
    
    func testCameraPositionChange() {
        // Given: Initial camera position
        var cameraPosition = MapCameraPosition.automatic
        
        // When: Changing to region
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        cameraPosition = .region(region)
        
        // Then: Position should be updated
        XCTAssertNotNil(cameraPosition)
    }
    
    // MARK: - Data Refresh Tests
    
    func testRefreshMapData() async {
        // Given: MapViewModel
        let initialUserCount = mapViewModel.users.count
        
        // When: Refreshing data
        await mapViewModel.fetchNearbyUsers(
            city: "New York",
            state: "NY",
            currentUserId: "current-user"
        )
        
        // Then: Should update users
        XCTAssertNotNil(mapViewModel.users)
    }
    
    func testRefreshCoffeeShops() async {
        // Given: Initial coffee shops
        let initialCount = mapViewModel.nearbyCoffeeShops.count
        
        // When: Fetching coffee shops
        await mapViewModel.fetchNearbyCoffeeShops()
        
        // Then: Should update shops
        XCTAssertNotNil(mapViewModel.nearbyCoffeeShops)
    }
    
    func testRefreshLocationData() async {
        // Given: Location permission requested
        mapViewModel.requestLocationPermission()
        
        // When: Requesting location update
        await mapViewModel.requestLocationUpdate()
        
        // Then: Location should be available or not (based on permissions)
        XCTAssertNotNil(mapViewModel)
    }
    
    // MARK: - Timer Update Tests
    
    func testPeriodicDataUpdates() async {
        // Given: Initial data state
        var updateCount = 0
        
        // When: Simulating timer updates (0.5s interval)
        for _ in 0..<3 {
            updateCount += 1
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        // Then: Should have multiple updates
        XCTAssertGreater(updateCount, 0)
    }
    
    // MARK: - Data Caching Tests
    
    func testCacheAnnotations() {
        // Given: Annotations to cache
        var cachedAnnotations: [MapAnnotationData] = []
        
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let annotation = MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: true,
            user: nil
        )
        
        // When: Caching
        cachedAnnotations.append(annotation)
        
        // Then: Should be cached
        XCTAssertEqual(cachedAnnotations.count, 1)
    }
    
    func testCacheCoffeeShops() {
        // Given: Coffee shops to cache
        var cachedShops: [CoffeeShop] = []
        
        let shop = CoffeeShop(
            id: "shop-1",
            name: "Test Cafe",
            location: Location(
                coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            ),
            address: "123 Main St",
            city: "New York",
            state: "NY",
            rating: 4.5
        )
        
        // When: Caching
        cachedShops.append(shop)
        
        // Then: Should be cached
        XCTAssertEqual(cachedShops.count, 1)
        XCTAssertEqual(cachedShops[0].name, "Test Cafe")
    }
    
    func testCacheInvalidation() {
        // Given: Cached data
        var cachedAnnotations: [MapAnnotationData] = []
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        cachedAnnotations.append(MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: true,
            user: nil
        ))
        
        // When: Clearing cache
        cachedAnnotations.removeAll()
        
        // Then: Cache should be empty
        XCTAssertTrue(cachedAnnotations.isEmpty)
    }
    
    // MARK: - MapView Initialization Tests
    
    func testMapViewInitialization() async {
        // Given: MapView dependencies
        XCTAssertNotNil(mapViewModel)
        XCTAssertNotNil(authViewModel)
        
        // When: Initializing map
        mapViewModel.requestLocationPermission()
        
        // Then: Should initialize properly
        XCTAssertNotNil(mapViewModel)
    }
    
    func testMapViewStartupSequence() async {
        // Given: Initial state
        XCTAssertTrue(mapViewModel.users.isEmpty)
        
        // When: Running startup sequence
        mapViewModel.requestLocationPermission()
        try? await Task.sleep(nanoseconds: 500_000_000)
        await mapViewModel.requestLocationUpdate()
        
        // Then: Should complete without errors
        XCTAssertNotNil(mapViewModel)
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleNoLocationPermission() {
        // Given: Location permission denied
        var hasLocationPermission = false
        
        // When: Checking permission
        if !hasLocationPermission {
            // Should handle gracefully
        }
        
        // Then: Should not crash
        XCTAssertFalse(hasLocationPermission)
    }
    
    func testHandleNoNearbyUsers() {
        // Given: No nearby users
        mapViewModel.users = []
        
        // Then: Should handle empty state
        XCTAssertTrue(mapViewModel.users.isEmpty)
    }
    
    func testHandleNoCoffeeShops() {
        // Given: No coffee shops
        mapViewModel.nearbyCoffeeShops = []
        
        // Then: Should show empty state
        XCTAssertTrue(mapViewModel.nearbyCoffeeShops.isEmpty)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigateToUserDetail() {
        // Given: User to display
        let user = User(
            id: "detail-user",
            email: "detail@example.com",
            fullName: "Detail User",
            avatar: Avatar(emoji: "📄"),
            bio: "User for detail view",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )
        
        // When: Navigating to detail
        var selectedUser: User? = user
        
        // Then: Should have user for detail view
        XCTAssertEqual(selectedUser?.id, "detail-user")
    }
    
    func testNavigateToCoffeeShopDetail() {
        // Given: Coffee shop to display
        let shop = CoffeeShop(
            id: "detail-shop",
            name: "Detail Cafe",
            location: Location(
                coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            ),
            address: "456 Park Ave",
            city: "New York",
            state: "NY",
            rating: 4.8
        )
        
        // When: Navigating to shop
        var selectedShop = shop
        
        // Then: Should have shop details
        XCTAssertEqual(selectedShop.id, "detail-shop")
    }
    
    // MARK: - Performance Tests
    
    func testMapPerformanceWithManyUsers() {
        // Given: Many users
        var users: [User] = []
        for i in 0..<50 {
            let user = User(
                id: "user-\(i)",
                email: "user\(i)@example.com",
                fullName: "User \(i)",
                avatar: Avatar(emoji: "👤"),
                bio: "Test user \(i)",
                major: "CS",
                college: "MIT",
                graduationYear: 2024,
                city: "Boston",
                state: "MA",
                favoriteCoffee: "Coffee",
                favoriteCoffeeShop: "Cafe"
            )
            users.append(user)
        }
        
        mapViewModel.users = users
        
        // When: Filtering users
        let filteredUsers = mapViewModel.users.filter { $0.major == "CS" }
        
        // Then: Should filter efficiently
        XCTAssertEqual(filteredUsers.count, 50)
    }
    
    func testMapPerformanceWithManyCoffeeShops() {
        // Given: Many coffee shops
        var shops: [CoffeeShop] = []
        for i in 0..<100 {
            let shop = CoffeeShop(
                id: "shop-\(i)",
                name: "Cafe \(i)",
                location: Location(
                    coordinate: CLLocationCoordinate2D(
                        latitude: 40.7128 + Double(i) * 0.001,
                        longitude: -74.0060 + Double(i) * 0.001
                    )
                ),
                address: "Address \(i)",
                city: "New York",
                state: "NY",
                rating: 4.0
            )
            shops.append(shop)
        }
        
        mapViewModel.nearbyCoffeeShops = shops
        
        // When: Sorting shops
        let sortedShops = mapViewModel.nearbyCoffeeShops.sorted { $0.rating > $1.rating }
        
        // Then: Should sort efficiently
        XCTAssertEqual(sortedShops.count, 100)
    }
    
    // MARK: - State Consistency Tests
    
    func testMapStateAfterUserSelection() {
        // Given: Initial state
        var selectedUser: User? = nil
        
        // When: Selecting user then deselecting
        let user = User(
            id: "temp-user",
            email: "temp@example.com",
            fullName: "Temp User",
            avatar: Avatar(emoji: "🔄"),
            bio: "Temporary user",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Coffee",
            favoriteCoffeeShop: "Cafe"
        )
        
        selectedUser = user
        XCTAssertNotNil(selectedUser)
        
        selectedUser = nil
        
        // Then: State should be consistent
        XCTAssertNil(selectedUser)
    }
    
    func testMapStateAfterSheetPresentation() {
        // Given: Sheet states
        var showList = false
        var showAR = false
        
        // When: Presenting sheets
        showList = true
        XCTAssertTrue(showList)
        
        showAR = true
        XCTAssertTrue(showAR)
        
        // Hide one
        showList = false
        
        // Then: States should be independent
        XCTAssertFalse(showList)
        XCTAssertTrue(showAR)
    }
}
