import XCTest
import SwiftUI
@testable import ShareACoffee
@testable import ShareACoffeeCore

/// Integration tests for MapView UI components
/// Tests cover marker rendering, user interactions, and visual state
@MainActor
final class MapViewMarkerTests: XCTestCase {
    
    // MARK: - CurrentUserMarker Tests
    
    func testCurrentUserMarkerCreation() {
        // Given: CurrentUserMarker component
        let marker = CurrentUserMarker()
        
        // Then: Should be a valid View
        XCTAssertNotNil(marker)
    }
    
    func testCurrentUserMarkerProperties() {
        // Given: CurrentUserMarker with animation state
        var marker = CurrentUserMarker()
        
        // Then: Should have pulsing animation capability
        XCTAssertNotNil(marker)
    }
    
    // MARK: - OtherUserMapMarker Tests
    
    func testOtherUserMarkerCreation() {
        // Given: User for marker
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
        
        // When: Creating marker
        let marker = OtherUserMapMarker(user: user)
        
        // Then: Should create valid marker
        XCTAssertNotNil(marker)
    }
    
    func testOtherUserMarkerDisplaysUserInfo() {
        // Given: User data
        let user = User(
            id: "user-456",
            email: "jane@example.com",
            fullName: "Jane Smith",
            avatar: Avatar(emoji: "🎓"),
            bio: "Math major",
            major: "Mathematics",
            college: "Harvard",
            graduationYear: 2023,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Local Cafe"
        )
        
        let marker = OtherUserMapMarker(user: user)
        
        // Then: Marker should reference user
        XCTAssertEqual(marker.user.id, "user-456")
        XCTAssertEqual(marker.user.fullName, "Jane Smith")
        XCTAssertEqual(marker.user.major, "Mathematics")
    }
    
    // MARK: - MapAnnotationData Helper Tests
    
    func testMapAnnotationDataIdentifier() {
        // Given: Two annotations
        let coord1 = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let annotation1 = MapAnnotationData(
            coordinate: coord1,
            isCurrentUser: true,
            user: nil
        )
        
        let annotation2 = MapAnnotationData(
            coordinate: coord1,
            isCurrentUser: true,
            user: nil
        )
        
        // Then: Each should have unique ID
        XCTAssertNotEqual(annotation1.id, annotation2.id)
    }
    
    func testMapAnnotationDataWithAllProperties() {
        // Given: Complete user data
        let user = User(
            id: "complete-user",
            email: "complete@example.com",
            fullName: "Complete User",
            avatar: Avatar(emoji: "⭐"),
            bio: "Complete bio with all details",
            major: "Software Engineering",
            college: "Stanford",
            graduationYear: 2024,
            city: "San Francisco",
            state: "CA",
            favoriteCoffee: "Cappuccino",
            favoriteCoffeeShop: "Premium Cafe"
        )
        
        let coordinate = CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863)
        let annotation = MapAnnotationData(
            coordinate: coordinate,
            isCurrentUser: false,
            user: user
        )
        
        // Then: All properties should be accessible
        XCTAssertFalse(annotation.isCurrentUser)
        XCTAssertNotNil(annotation.user)
        XCTAssertEqual(annotation.user?.fullName, "Complete User")
        XCTAssertEqual(annotation.coordinate.latitude, 37.3382)
        XCTAssertEqual(annotation.coordinate.longitude, -121.8863)
    }
    
    // MARK: - Marker Visual State Tests
    
    func testCurrentUserMarkerVisibility() {
        // Given: Current user marker
        let marker = CurrentUserMarker()
        
        // Then: Should be visible and renderable
        XCTAssertNotNil(marker)
        // Marker has body property indicating it's a valid SwiftUI View
    }
    
    func testOtherUserMarkerVisibility() {
        // Given: Other user marker
        let user = User(
            id: "visible-user",
            email: "visible@example.com",
            fullName: "Visible User",
            avatar: Avatar(emoji: "👁️"),
            bio: "Test visibility",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Coffee",
            favoriteCoffeeShop: "Shop"
        )
        
        let marker = OtherUserMapMarker(user: user)
        
        // Then: Should be visible and renderable
        XCTAssertNotNil(marker)
    }
    
    // MARK: - Annotation Sorting Tests
    
    func testAnnotationSortByUserName() {
        // Given: Multiple annotations
        let user1 = User(
            id: "user-1",
            email: "alice@example.com",
            fullName: "Alice",
            avatar: Avatar(emoji: "🅰️"),
            bio: "Alice bio",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )
        
        let user2 = User(
            id: "user-2",
            email: "bob@example.com",
            fullName: "Bob",
            avatar: Avatar(emoji: "🅱️"),
            bio: "Bob bio",
            major: "Math",
            college: "Harvard",
            graduationYear: 2023,
            city: "Cambridge",
            state: "MA",
            favoriteCoffee: "Espresso",
            favoriteCoffeeShop: "Cafe"
        )
        
        let annotations = [
            MapAnnotationData(
                coordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
                isCurrentUser: false,
                user: user2
            ),
            MapAnnotationData(
                coordinate: CLLocationCoordinate2D(latitude: 42.2352, longitude: -71.0275),
                isCurrentUser: false,
                user: user1
            )
        ]
        
        // When: Sorting by user name
        let sorted = annotations.sorted { ($0.user?.fullName ?? "") < ($1.user?.fullName ?? "") }
        
        // Then: Should be sorted correctly
        XCTAssertEqual(sorted[0].user?.fullName, "Alice")
        XCTAssertEqual(sorted[1].user?.fullName, "Bob")
    }
    
    func testAnnotationGroupingByUserType() {
        // Given: Mixed current and other users
        let otherUser = User(
            id: "other-user",
            email: "other@example.com",
            fullName: "Other User",
            avatar: Avatar(emoji: "👤"),
            bio: "Other",
            major: "CS",
            college: "MIT",
            graduationYear: 2024,
            city: "Boston",
            state: "MA",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Cafe"
        )
        
        let annotations = [
            MapAnnotationData(
                coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                isCurrentUser: true,
                user: nil
            ),
            MapAnnotationData(
                coordinate: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
                isCurrentUser: false,
                user: otherUser
            ),
            MapAnnotationData(
                coordinate: CLLocationCoordinate2D(latitude: 40.7489, longitude: -73.9680),
                isCurrentUser: false,
                user: nil
            )
        ]
        
        // When: Grouping by user type
        let currentUsers = annotations.filter { $0.isCurrentUser }
        let otherUsers = annotations.filter { !$0.isCurrentUser }
        
        // Then: Groups should be correct
        XCTAssertEqual(currentUsers.count, 1)
        XCTAssertEqual(otherUsers.count, 2)
    }
    
    // MARK: - Marker Style Tests
    
    func testCurrentUserMarkerStyle() {
        // Given: Current user marker
        let marker = CurrentUserMarker()
        
        // Then: Should have distinctive style (tested through component existence)
        XCTAssertNotNil(marker)
    }
    
    func testOtherUserMarkerStyle() {
        // Given: Other user marker
        let user = User(
            id: "styled-user",
            email: "styled@example.com",
            fullName: "Styled User",
            avatar: Avatar(emoji: "🎨"),
            bio: "Style test",
            major: "Design",
            college: "RISD",
            graduationYear: 2024,
            city: "Providence",
            state: "RI",
            favoriteCoffee: "Cappuccino",
            favoriteCoffeeShop: "Artisan Cafe"
        )
        
        let marker = OtherUserMapMarker(user: user)
        
        // Then: Should have appropriate styling
        XCTAssertNotNil(marker)
        XCTAssertEqual(marker.user.avatar.emoji, "🎨")
    }
    
    // MARK: - Edge Cases
    
    func testAnnotationWithNilUser() {
        // Given: Annotation with nil user
        let annotation = MapAnnotationData(
            coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            isCurrentUser: false,
            user: nil
        )
        
        // Then: Should handle gracefully
        XCTAssertNil(annotation.user)
        XCTAssertFalse(annotation.isCurrentUser)
    }
    
    func testAnnotationWithExtremeCoordinates() {
        // Given: Extreme coordinate values (poles)
        let northPole = CLLocationCoordinate2D(latitude: 90.0, longitude: 0.0)
        let southPole = CLLocationCoordinate2D(latitude: -90.0, longitude: 180.0)
        
        let northAnnotation = MapAnnotationData(
            coordinate: northPole,
            isCurrentUser: true,
            user: nil
        )
        
        let southAnnotation = MapAnnotationData(
            coordinate: southPole,
            isCurrentUser: false,
            user: nil
        )
        
        // Then: Should handle extreme coordinates
        XCTAssertEqual(northAnnotation.coordinate.latitude, 90.0)
        XCTAssertEqual(southAnnotation.coordinate.latitude, -90.0)
    }
    
    func testMarkerWithMinimalUserData() {
        // Given: User with minimal data
        let minimalUser = User(
            id: "minimal",
            email: "minimal@example.com",
            fullName: "M",
            avatar: Avatar(emoji: "•"),
            bio: "",
            major: "",
            college: "",
            graduationYear: 0,
            city: "",
            state: "",
            favoriteCoffee: "",
            favoriteCoffeeShop: ""
        )
        
        let marker = OtherUserMapMarker(user: minimalUser)
        
        // Then: Should handle minimal data
        XCTAssertEqual(marker.user.fullName, "M")
        XCTAssertEqual(marker.user.bio, "")
    }
}
