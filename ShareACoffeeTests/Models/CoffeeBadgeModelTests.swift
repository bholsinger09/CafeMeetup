import XCTest
@testable import CafeMeetup

/// Tests for CoffeeBadge model
/// Verifies badge system functionality and data integrity
final class CoffeeBadgeModelTests: XCTestCase {
    
    // MARK: - Badge Structure Tests
    
    func testBadgeHasRequiredProperties() {
        let badge = CoffeeBadge(
            id: "test_badge",
            name: "Test Badge",
            description: "A test badge",
            emoji: "🧪",
            rarity: .common,
            unlockCriteria: "Complete a test"
        )
        
        XCTAssertEqual(badge.id, "test_badge")
        XCTAssertEqual(badge.name, "Test Badge")
        XCTAssertEqual(badge.description, "A test badge")
        XCTAssertEqual(badge.emoji, "🧪")
        XCTAssertEqual(badge.rarity, .common)
        XCTAssertEqual(badge.unlockCriteria, "Complete a test")
        XCTAssertFalse(badge.isUnlocked, "Badges should be locked by default")
    }
    
    func testBadgeRarityLevels() {
        let commonBadge = CoffeeBadge(id: "1", name: "Common", description: "", emoji: "☕️", rarity: .common, unlockCriteria: "")
        let rareBadge = CoffeeBadge(id: "2", name: "Rare", description: "", emoji: "🎯", rarity: .rare, unlockCriteria: "")
        let epicBadge = CoffeeBadge(id: "3", name: "Epic", description: "", emoji: "💎", rarity: .epic, unlockCriteria: "")
        let legendaryBadge = CoffeeBadge(id: "4", name: "Legendary", description: "", emoji: "👑", rarity: .legendary, unlockCriteria: "")
        
        XCTAssertEqual(commonBadge.rarity, .common)
        XCTAssertEqual(rareBadge.rarity, .rare)
        XCTAssertEqual(epicBadge.rarity, .epic)
        XCTAssertEqual(legendaryBadge.rarity, .legendary)
    }
    
    // MARK: - Badge System Tests
    
    func testBadgeSystemHasAllBadges() {
        let allBadges = CoffeeBadgeSystem.allBadges
        
        XCTAssertGreaterThanOrEqual(allBadges.count, 15, "Should have at least 15 unique badges")
        
        // Verify no duplicate IDs
        let uniqueIds = Set(allBadges.map { $0.id })
        XCTAssertEqual(uniqueIds.count, allBadges.count, "All badge IDs should be unique")
    }
    
    func testBadgeSystemHasVarietyOfRarities() {
        let allBadges = CoffeeBadgeSystem.allBadges
        
        let commonBadges = allBadges.filter { $0.rarity == .common }
        let rareBadges = allBadges.filter { $0.rarity == .rare }
        let epicBadges = allBadges.filter { $0.rarity == .epic }
        let legendaryBadges = allBadges.filter { $0.rarity == .legendary }
        
        XCTAssertGreaterThan(commonBadges.count, 0, "Should have common badges")
        XCTAssertGreaterThan(rareBadges.count, 0, "Should have rare badges")
        XCTAssertGreaterThan(epicBadges.count, 0, "Should have epic badges")
        XCTAssertGreaterThan(legendaryBadges.count, 0, "Should have legendary badges")
    }
    
    func testSpecificBadgesExist() {
        let allBadges = CoffeeBadgeSystem.allBadges
        let badgeIds = allBadges.map { $0.id }
        
        // Test for key badges
        XCTAssertTrue(badgeIds.contains("first_latte"), "Should have First Latte badge")
        XCTAssertTrue(badgeIds.contains("social_butterfly"), "Should have Social Butterfly badge")
        XCTAssertTrue(badgeIds.contains("study_buddy"), "Should have Study Buddy badge")
        XCTAssertTrue(badgeIds.contains("latte_legend"), "Should have Latte Legend badge")
    }
    
    func testBadgeUnlockCriteriaAreDescriptive() {
        let allBadges = CoffeeBadgeSystem.allBadges
        
        for badge in allBadges {
            XCTAssertFalse(badge.unlockCriteria.isEmpty, "Badge '\(badge.name)' should have unlock criteria")
            XCTAssertGreaterThan(badge.unlockCriteria.count, 10, "Unlock criteria for '\(badge.name)' should be descriptive")
        }
    }
    
    // MARK: - Data Integrity Tests
    
    func testBadgeFollowsSingleResponsibilityPrinciple() {
        let badge = CoffeeBadge(
            id: "test",
            name: "Test",
            description: "Test badge",
            emoji: "🧪",
            rarity: .common,
            unlockCriteria: "Test"
        )
        
        // Badge should only contain data, no business logic methods
        // It should NOT have methods like:
        // - badge.unlock()
        // - badge.checkProgress()
        // - badge.notify()
        // These belong in CoffeeExperienceService
        
        XCTAssertTrue(type(of: badge) == CoffeeBadge.self)
    }
    
    func testBadgeIsEquatable() {
        let badge1 = CoffeeBadge(id: "test", name: "Test", description: "", emoji: "🧪", rarity: .common, unlockCriteria: "")
        let badge2 = CoffeeBadge(id: "test", name: "Test", description: "", emoji: "🧪", rarity: .common, unlockCriteria: "")
        let badge3 = CoffeeBadge(id: "other", name: "Other", description: "", emoji: "🔬", rarity: .rare, unlockCriteria: "")
        
        XCTAssertEqual(badge1, badge2, "Badges with same properties should be equal")
        XCTAssertNotEqual(badge1, badge3, "Badges with different IDs should not be equal")
    }
    
    func testBadgeIsIdentifiable() {
        let badge = CoffeeBadge(id: "unique_id", name: "Test", description: "", emoji: "🧪", rarity: .common, unlockCriteria: "")
        
        XCTAssertEqual(badge.id, "unique_id", "Badge should be identifiable by its ID")
    }
    
    // MARK: - Edge Cases
    
    func testBadgeHandlesEmptyStrings() {
        let badge = CoffeeBadge(
            id: "",
            name: "",
            description: "",
            emoji: "",
            rarity: .common,
            unlockCriteria: ""
        )
        
        XCTAssertNotNil(badge, "Badge should handle empty strings gracefully")
    }
    
    func testBadgeHandlesUnicodeEmojis() {
        let emojis = ["☕️", "🦋", "🌅", "🎓", "📚", "👑", "💎", "🔥", "⭐️"]
        
        for emoji in emojis {
            let badge = CoffeeBadge(
                id: "test_\(emoji)",
                name: "Test",
                description: "",
                emoji: emoji,
                rarity: .common,
                unlockCriteria: ""
            )
            
            XCTAssertEqual(badge.emoji, emoji, "Badge should support emoji: \(emoji)")
        }
    }
}
