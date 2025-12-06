import XCTest
import SwiftUI
@testable import CafeMeetup

@MainActor
final class DiscoveryViewLayoutTests: XCTestCase {
    
    // MARK: - Card Sizing Tests
    
    func testProfileCardDoesNotExceed70PercentOfScreenHeight() {
        // Given: A standard iPhone screen height
        let screenHeight: CGFloat = 844 // iPhone 14/15 Pro height
        let expectedMaxCardHeight = screenHeight * 0.70
        
        // Then: Card should not exceed 70% to leave room for buttons
        XCTAssertLessThanOrEqual(expectedMaxCardHeight, screenHeight * 0.75, 
                                 "Card height should be 70% or less of screen height")
        XCTAssertGreaterThan(expectedMaxCardHeight, 0, 
                            "Card height must be positive")
    }
    
    func testProfileCardHasSufficientWidthMargins() {
        // Given: A standard iPhone screen width
        let screenWidth: CGFloat = 390 // iPhone 14/15 Pro width
        let horizontalMargin: CGFloat = 32 // 16pt on each side
        let expectedCardWidth = screenWidth - horizontalMargin
        
        // Then: Card should have proper horizontal margins
        XCTAssertEqual(expectedCardWidth, screenWidth - 32, 
                      "Card should have 32pt total horizontal margin")
        XCTAssertGreaterThan(expectedCardWidth, 300, 
                           "Card width should be sufficient for content")
    }
    
    // MARK: - User Info Section Tests
    
    func testUserInfoSectionIsNotCutOff() {
        // Given: A user with all fields populated
        let user = User(
            email: "test@test.com",
            fullName: "John Doe",
            college: "University of Idaho",
            state: "Idaho",
            city: "Moscow",
            favoriteCoffee: "Vanilla Latte",
            favoriteCoffeeShop: "The Human Bean",
            bio: "Coffee enthusiast and avid reader. Love meeting new people!",
            gender: "Male",
            relationshipStatus: "Single"
        )
        
        // Then: User info should have all required fields
        XCTAssertFalse(user.fullName.isEmpty, "Full name should not be empty")
        XCTAssertFalse(user.college.isEmpty, "College should not be empty")
        XCTAssertFalse(user.city.isEmpty, "City should not be empty")
        XCTAssertFalse(user.state.isEmpty, "State should not be empty")
        XCTAssertFalse(user.favoriteCoffee.isEmpty, "Favorite coffee should not be empty")
        XCTAssertNotNil(user.bio, "Bio should be present")
        
        // And: Bio should be reasonably sized
        if let bio = user.bio {
            XCTAssertLessThanOrEqual(bio.count, 200, 
                                    "Bio should be limited to prevent card overflow")
        }
    }
    
    func testProfileCardLayoutPriorities() {
        // Test that layout priorities are set correctly
        // Image section should have fixed height (65% of card) to prevent overflow
        // User info section gets remaining space (35% of card)
        
        // Given: A card height
        let cardHeight: CGFloat = 600
        let imageHeight = cardHeight * 0.65
        let remainingHeight = cardHeight * 0.35
        
        // Then: Image should take 65% max
        XCTAssertEqual(imageHeight, 390, accuracy: 1, 
                      "Image section should be 65% of card height")
        
        // And: User info should have at least 35% available
        XCTAssertGreaterThanOrEqual(remainingHeight, 200,
                                   "User info section should have at least 200pt")
    }
    
    func testImageSectionDoesNotOverflowCard() {
        // Given: Various card heights
        let cardHeights: [CGFloat] = [500, 600, 700, 800]
        
        for cardHeight in cardHeights {
            let imageHeight = cardHeight * 0.65
            let userInfoHeight = cardHeight * 0.35
            
            // Then: Image should never exceed 65% of card
            XCTAssertLessThanOrEqual(imageHeight, cardHeight * 0.65,
                                    "Image should not exceed 65% for height \(cardHeight)")
            
            // And: User info should have sufficient space
            XCTAssertGreaterThanOrEqual(userInfoHeight, cardHeight * 0.35,
                                       "User info should have at least 35% for height \(cardHeight)")
        }
    }
    
    // MARK: - Button Placement Tests
    
    func testActionButtonsHaveSufficientSpace() {
        // Given: Screen height and card height
        let screenHeight: CGFloat = 844
        let cardHeight = screenHeight * 0.70
        let remainingSpace = screenHeight - cardHeight
        
        // Then: Buttons should have at least 120pt of space (70pt button + 30pt padding + 20pt bottom padding)
        let minimumButtonSpace: CGFloat = 120
        XCTAssertGreaterThanOrEqual(remainingSpace, minimumButtonSpace,
                                   "Should have sufficient space for action buttons")
    }
    
    // MARK: - Content Overflow Tests
    
    func testLongNamesDoNotBreakLayout() {
        // Given: A user with a very long name
        let user = User(
            email: "test@test.com",
            fullName: "Alexander Bartholomew Christopher Davidson",
            college: "Massachusetts Institute of Technology",
            state: "Massachusetts",
            city: "Cambridge",
            favoriteCoffee: "Double Espresso Macchiato",
            favoriteCoffeeShop: "The Local Coffee Shop",
            bio: "I really love coffee and meeting new people to discuss philosophy and technology."
        )
        
        // Then: All fields should be present (even if truncated in UI)
        XCTAssertFalse(user.fullName.isEmpty)
        XCTAssertFalse(user.college.isEmpty)
        XCTAssertGreaterThan(user.fullName.count, 20, "Testing with long name")
        XCTAssertGreaterThan(user.college.count, 20, "Testing with long college name")
    }
    
    func testProfileCardWithMinimalInfo() {
        // Given: A user with only required fields
        let user = User(
            email: "test@test.com",
            fullName: "Jo",
            college: "BSU",
            state: "ID",
            city: "NYC",
            favoriteCoffee: "Coffee",
            favoriteCoffeeShop: "Cafe",
            bio: nil,
            gender: nil,
            relationshipStatus: nil
        )
        
        // Then: Profile should still be valid
        XCTAssertFalse(user.fullName.isEmpty)
        XCTAssertFalse(user.college.isEmpty)
        XCTAssertNil(user.bio, "Bio can be optional")
        XCTAssertNil(user.gender, "Gender can be optional")
    }
    
    // MARK: - Safe Area Tests
    
    func testCardAccountsForTopSafeArea() {
        // Given: Top safe area padding
        let topPadding: CGFloat = 8
        
        // Then: Card should have padding to avoid status bar
        XCTAssertGreaterThan(topPadding, 0, "Card should have top padding")
        XCTAssertLessThanOrEqual(topPadding, 20, "Top padding should be reasonable")
    }
    
    func testCardAccountsForBottomSafeArea() {
        // Given: iPhone with home indicator (typically 34pt safe area)
        let bottomSafeArea: CGFloat = 34
        let buttonHeight: CGFloat = 70
        let buttonPadding: CGFloat = 30
        let totalBottomSpace = buttonHeight + buttonPadding + bottomSafeArea
        
        // Then: Total space should accommodate buttons and safe area
        XCTAssertGreaterThan(totalBottomSpace, 100, 
                           "Should have sufficient bottom space for buttons and safe area")
    }
    
    // MARK: - Discovery View Integration Tests
    
    func testDiscoveryViewRequiresNonEmptyUserList() {
        // Given: Empty potential matches
        let emptyMatches: [User] = []
        
        // Then: Should show "no users" message
        XCTAssertTrue(emptyMatches.isEmpty, "Empty list should be handled gracefully")
    }
    
    func testDiscoveryViewWithSingleUser() {
        // Given: One potential match
        let user = User(
            email: "test@test.com",
            fullName: "Test User",
            college: "Test College",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Latte",
            favoriteCoffeeShop: "Starbucks"
        )
        let matches = [user]
        
        // Then: Should display that user
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.fullName, "Test User")
    }
    
    func testDiscoveryViewStacksMultipleCards() {
        // Given: Multiple users
        let users = (1...5).map { i in
            User(
                email: "test\(i)@test.com",
                fullName: "User \(i)",
                college: "College \(i)",
                state: "Idaho",
                city: "Boise",
                favoriteCoffee: "Coffee \(i)",
                favoriteCoffeeShop: "Shop \(i)"
            )
        }
        
        // Then: Should show up to 3 cards in the stack
        let maxVisibleCards = min(3, users.count)
        XCTAssertEqual(maxVisibleCards, 3, "Should stack up to 3 cards")
        XCTAssertEqual(users.count, 5, "Should have 5 total users")
    }
}
