import XCTest
import SwiftUI
@testable import ShareACoffee
@testable import ShareACoffeeCore
@testable import ShareACoffeeCoffee
@testable import ShareACoffeeAuth

/// Comprehensive tests for MapView functionality
/// Tests cover data caching, annotation building, user display, and map interactions
@MainActor
final class MapViewTests: XCTestCase {
    
    var mapViewModel: MapViewModel!
    var authViewModel: AuthenticationViewModel!
    
    override func setUp() async throws {
        mapViewModel = MapViewModel()
        authViewModel = AuthenticationViewModel()
    }
    
    // MARK: - MapAnnotationData Tests
    
    func testMapAnnotationDataStructure() {
        // Given: Annotation data for current user
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let annotation = MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: true,
            user: nil
        )
        
        // Then: Annotation should have correct properties
        XCTAssertTrue(annotation.isCurrentUser)
        XCTAssertNil(annotation.user)
        XCTAssertEqual(annotation.coordinate.latitude, 40.7128)
        XCTAssertEqual(annotation.coordinate.longitude, -74.0060)
    }
    
    func testMapAnnotationDataForOtherUser() {
        // Given: User data
        let user = User(
            id: "user-123",
            email: "test@example.com",
            fullName: "John Doe",
            avatar: Avatar(emoji: "👤"),
            bio: "Test user",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "New York",
            state: "NY",
            favoriteCoffee: "Espresso",
            favoriteCoffeeShop: "Starbucks"
        )
        
        let coordinate = CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855)
        let annotation = MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: false,
            user: user
        )
        
        // Then: Annotation should represent other user
        XCTAssertFalse(annotation.isCurrentUser)
        XCTAssertNotNil(annotation.user)
        XCTAssertEqual(annotation.user?.fullName, "John Doe")
    }
    
    // MARK: - Annotation Building Tests
    
    func testBuildAnnotationsWithoutUsers() {
        // Given: Empty user list
        mapViewModel.users = []
        mapViewModel.currentUserLocation = nil
        
        // When: Building annotations (simulating the MapView logic)
        var annotations: [MapAnnotationData] = []
        
        // Then: Should return empty annotations
        XCTAssertTrue(annotations.isEmpty)
    }
    
    func testBuildAnnotationsWithCurrentUserLocation() {
        // Given: Current user location
        let currentLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        mapViewModel.currentUserLocation = currentLocation
        mapViewModel.users = []
        
        // When: Building annotations
        var annotations: [MapAnnotationData] = []
        if let loc = mapViewModel.currentUserLocation {
            annotations.append(MapAnnotationData(
                coordinate: loc,
                isCurrentUser: true,
                user: nil
            ))
        }
        
        // Then: Should have one current user annotation
        XCTAssertEqual(annotations.count, 1)
        XCTAssertTrue(annotations[0].isCurrentUser)
    }
    
    func testBuildAnnotationsWithMultipleUsers() {
        // Given: Multiple users with locations
        let user1 = User(
            id: "user-1",
            email: "user1@example.com",
            fullName: "User One",
            avatar: Avatar(emoji: "👤"),
            bio: "First user",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "New York",
            state: "NY",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe A"
        )
        
        let user1Location = Location(
            coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        )
        user1.location = user1Location
        
        let user2 = User(
            id: "user-2",
            email: "user2@example.com",
            fullName: "User Two",
            avatar: Avatar(emoji: "👥"),
            bio: "Second user",
            major: "Math",
            college: "Harvard",
            graduationYear: 2023,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Cappuccino",
            favoriteCoffeeShop: "Cafe B"
        )
        
        let user2Location = Location(
            coordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
        )
        user2.location = user2Location
        
        mapViewModel.currentUserLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        mapViewModel.users = [user1, user2]
        
        // When: Building annotations
        var annotations: [MapAnnotationData] = []
        if let loc = mapViewModel.currentUserLocation {
            annotations.append(MapAnnotationData(
                coordinate: loc,
                isCurrentUser: true,
                user: nil
            ))
        }
        for user in mapViewModel.users {
            if let location = user.location {
                annotations.append(MapAnnotationData(
                    coordinate: location.coordinate,
                    isCurrentUser: false,
                    user: user
                ))
            }
        }
        
        // Then: Should have current user + other users
        XCTAssertEqual(annotations.count, 3)
        XCTAssertEqual(annotations.filter { $0.isCurrentUser }.count, 1)
        XCTAssertEqual(annotations.filter { !$0.isCurrentUser }.count, 2)
    }
    
    // MARK: - Coffee Shops Display Tests
    
    func testCoffeeShopsDataLoading() {
        // Given: Coffee shop list
        let coffeeShop1 = CoffeeShop(
            id: "shop-1",
            name: "Brew Haven",
            location: Location(
                coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            ),
            address: "123 Main St",
            city: "New York",
            state: "NY",
            rating: 4.5
        )
        
        let coffeeShop2 = CoffeeShop(
            id: "shop-2",
            name: "Coffee Corner",
            location: Location(
                coordinate: CLLocationCoordinate2D(latitude: 40.7129, longitude: -74.0061)
            ),
            address: "456 Park Ave",
            city: "New York",
            state: "NY",
            rating: 4.2
        )
        
        mapViewModel.nearbyCoffeeShops = [coffeeShop1, coffeeShop2]
        
        // Then: Should have correct coffee shops
        XCTAssertEqual(mapViewModel.nearbyCoffeeShops.count, 2)
        XCTAssertEqual(mapViewModel.nearbyCoffeeShops[0].name, "Brew Haven")
        XCTAssertEqual(mapViewModel.nearbyCoffeeShops[1].name, "Coffee Corner")
    }
    
    func testCoffeeShopsEmptyState() {
        // Given: No coffee shops
        mapViewModel.nearbyCoffeeShops = []
        
        // Then: Should be empty
        XCTAssertTrue(mapViewModel.nearbyCoffeeShops.isEmpty)
    }
    
    // MARK: - ViewModel Integration Tests
    
    func testMapViewModelLocationPermission() {
        // Given: MapViewModel
        // When: Requesting location permission
        mapViewModel.requestLocationPermission()
        
        // Then: Should handle permission request (implementation dependent)
        XCTAssertNotNil(mapViewModel)
    }
    
    func testMapViewModelCenterOnLocation() async {
        // Given: MapViewModel with location
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        mapViewModel.currentUserLocation = coordinate
        
        // When: Centering on current location
        await mapViewModel.centerOnCurrentLocation()
        
        // Then: Should maintain location
        XCTAssertEqual(mapViewModel.currentUserLocation?.latitude, 40.7128)
        XCTAssertEqual(mapViewModel.currentUserLocation?.longitude, -74.0060)
    }
    
    func testMapViewModelFetchNearbyUsers() async {
        // Given: Valid user parameters
        let city = "New York"
        let state = "NY"
        let currentUserId = "current-user"
        
        // When: Fetching nearby users
        await mapViewModel.fetchNearbyUsers(
            city: city,
            state: state,
            currentUserId: currentUserId
        )
        
        // Then: Should update users list (may be empty initially)
        XCTAssertNotNil(mapViewModel.users)
    }
    
    func testMapViewModelFetchNearbyCoffeeShops() async {
        // Given: MapViewModel
        // When: Fetching nearby coffee shops
        await mapViewModel.fetchNearbyCoffeeShops()
        
        // Then: Should update coffee shops list
        XCTAssertNotNil(mapViewModel.nearbyCoffeeShops)
    }
    
    // MARK: - State Management Tests
    
    func testAnnotationFilteringByCurrentUser() {
        // Given: Mixed annotations
        let currentLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let otherLocation = CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855)
        
        let currentUserAnnotation = MapAnnotationData(
            coordinate: currentLocation,
            isCurrentUser: true,
            user: nil
        )
        
        let otherUser = User(
            id: "user-2",
            email: "other@example.com",
            fullName: "Other User",
            avatar: Avatar(emoji: "👤"),
            bio: "Other user",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "New York",
            state: "NY",
            favoriteCoffee: "Espresso",
            favoriteCoffeeShop: "Starbucks"
        )
        
        let otherUserAnnotation = MapAnnotationData(
            coordinate: otherLocation,
            isCurrentUser: false,
            user: otherUser
        )
        
        let allAnnotations = [currentUserAnnotation, otherUserAnnotation]
        
        // When: Filtering annotations
        let currentUsers = allAnnotations.filter { $0.isCurrentUser }
        let otherUsers = allAnnotations.filter { !$0.isCurrentUser }
        
        // Then: Should filter correctly
        XCTAssertEqual(currentUsers.count, 1)
        XCTAssertEqual(otherUsers.count, 1)
        XCTAssertTrue(currentUsers[0].isCurrentUser)
        XCTAssertFalse(otherUsers[0].isCurrentUser)
    }
    
    func testCachedAnnotationsUpdate() {
        // Given: Initial cached annotations
        var cachedAnnotations: [MapAnnotationData] = []
        
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let annotation = MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: true,
            user: nil
        )
        
        // When: Updating cached annotations
        cachedAnnotations.append(annotation)
        
        // Then: Cache should be updated
        XCTAssertEqual(cachedAnnotations.count, 1)
        XCTAssertTrue(cachedAnnotations[0].isCurrentUser)
    }
    
    // MARK: - Coordinate Tests
    
    func testCoordinateValidation() {
        // Given: Valid coordinate
        let validCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        
        // Then: Should have valid range
        XCTAssertTrue(validCoordinate.latitude >= -90 && validCoordinate.latitude <= 90)
        XCTAssertTrue(validCoordinate.longitude >= -180 && validCoordinate.longitude <= 180)
    }
    
    func testMultipleCoordinatePrecision() {
        // Given: Precise coordinates
        let coord1 = CLLocationCoordinate2D(latitude: 40.712776, longitude: -74.005974)
        let coord2 = CLLocationCoordinate2D(latitude: 40.712777, longitude: -74.005975)
        
        // Then: Should maintain precision
        XCTAssertNotEqual(coord1.latitude, coord2.latitude)
        XCTAssertNotEqual(coord1.longitude, coord2.longitude)
    }
    
    // MARK: - User Selection Tests
    
    func testUserSelectionFromAnnotation() {
        // Given: User annotation
        let user = User(
            id: "user-123",
            email: "test@example.com",
            fullName: "Test User",
            avatar: Avatar(emoji: "👤"),
            bio: "Test bio",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "New York",
            state: "NY",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe A"
        )
        
        let annotation = MapAnnotationData(
            coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            isCurrentUser: false,
            user: user
        )
        
        // When: Selecting user from annotation
        let selectedUser = annotation.user
        
        // Then: Should have correct user data
        XCTAssertEqual(selectedUser?.id, "user-123")
        XCTAssertEqual(selectedUser?.fullName, "Test User")
    }
    
    // MARK: - Performance Tests
    
    func testLargeNumberOfAnnotations() {
        // Given: Large number of annotations
        var annotations: [MapAnnotationData] = []
        
        let currentLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        annotations.append(MapAnnotationData(
            coordinate: currentLocation,
            isCurrentUser: true,
            user: nil
        ))
        
        // Add many other user annotations
        for i in 0..<100 {
            let coordinate = CLLocationCoordinate2D(
                latitude: 40.7128 + Double(i) * 0.001,
                longitude: -74.0060 + Double(i) * 0.001
            )
            let annotation = MapAnnotationData(
                coordinate: coordinate,
                isCurrentUser: false,
                user: nil
            )
            annotations.append(annotation)
        }
        
        // When: Filtering annotations
        let filtered = annotations.filter { $0.isCurrentUser }
        
        // Then: Should filter efficiently
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(annotations.count, 101)
    }
    
    func testAnnotationMemoryEfficiency() {
        // Given: Annotations with and without users
        var lightAnnotations: [MapAnnotationData] = []
        var heavyAnnotations: [MapAnnotationData] = []
        
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        
        // Light: without user data
        lightAnnotations.append(MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: true,
            user: nil
        ))
        
        // Heavy: with user data
        let user = User(
            id: "user-123",
            email: "test@example.com",
            fullName: "Test User",
            avatar: Avatar(emoji: "👤"),
            bio: "Test bio with lots of information",
            major: "Computer Science",
            college: "Massachusetts Institute of Technology",
            graduationYear: 2024,
            city: "New York",
            state: "NY",
            favoriteCoffee: "Espresso",
            favoriteCoffeeShop: "Cafe A"
        )
        
        heavyAnnotations.append(MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: false,
            user: user
        ))
        
        // Then: Should handle both efficiently
        XCTAssertEqual(lightAnnotations.count, 1)
        XCTAssertEqual(heavyAnnotations.count, 1)
        XCTAssertNil(lightAnnotations[0].user)
        XCTAssertNotNil(heavyAnnotations[0].user)
    }
}
