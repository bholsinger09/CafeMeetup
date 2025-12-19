import XCTest
@testable import CafeMeetup

final class AvatarModelTests: XCTestCase {
    
    // MARK: - Avatar Model Tests
    
    func testAvatarInitialization() {
        // Given
        let id = "spiderman"
        let name = "Spider-Man"
        let emoji = "🕷️"
        let category = Avatar.AvatarCategory.marvel
        
        // When
        let avatar = Avatar(id: id, name: name, emoji: emoji, category: category)
        
        // Then
        XCTAssertEqual(avatar.id, id)
        XCTAssertEqual(avatar.name, name)
        XCTAssertEqual(avatar.emoji, emoji)
        XCTAssertEqual(avatar.category, category)
    }
    
    func testAvatarConformsToIdentifiable() {
        // Given
        let avatar = Avatar(id: "batman", name: "Batman", emoji: "🦇", category: .dc)
        
        // Then
        XCTAssertNotNil(avatar.id)
    }
    
    func testAvatarConformsToCodable() {
        // Given
        let avatar = Avatar(id: "wednesday", name: "Wednesday Addams", emoji: "🖤", category: .cartoon)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        do {
            let data = try encoder.encode(avatar)
            let decodedAvatar = try decoder.decode(Avatar.self, from: data)
            
            // Then
            XCTAssertEqual(decodedAvatar.id, avatar.id)
            XCTAssertEqual(decodedAvatar.name, avatar.name)
            XCTAssertEqual(decodedAvatar.emoji, avatar.emoji)
            XCTAssertEqual(decodedAvatar.category, avatar.category)
        } catch {
            XCTFail("Avatar should be Codable: \(error)")
        }
    }
    
    func testAvatarEquatable() {
        // Given
        let avatar1 = Avatar(id: "hulk", name: "Hulk", emoji: "💚", category: .marvel)
        let avatar2 = Avatar(id: "hulk", name: "Hulk", emoji: "💚", category: .marvel)
        let avatar3 = Avatar(id: "thor", name: "Thor", emoji: "⚡", category: .marvel)
        
        // Then
        XCTAssertEqual(avatar1, avatar2)
        XCTAssertNotEqual(avatar1, avatar3)
    }
    
    // MARK: - Avatar Category Tests
    
    func testAvatarCategoryAllCases() {
        // Given
        let categories = Avatar.AvatarCategory.allCases
        
        // Then
        XCTAssertEqual(categories.count, 5)
        XCTAssertTrue(categories.contains(.marvel))
        XCTAssertTrue(categories.contains(.dc))
        XCTAssertTrue(categories.contains(.cartoon))
        XCTAssertTrue(categories.contains(.anime))
        XCTAssertTrue(categories.contains(.classic))
    }
    
    func testAvatarCategoryRawValues() {
        // Then
        XCTAssertEqual(Avatar.AvatarCategory.marvel.rawValue, "Marvel")
        XCTAssertEqual(Avatar.AvatarCategory.dc.rawValue, "DC")
        XCTAssertEqual(Avatar.AvatarCategory.cartoon.rawValue, "Cartoon")
        XCTAssertEqual(Avatar.AvatarCategory.anime.rawValue, "Anime")
        XCTAssertEqual(Avatar.AvatarCategory.classic.rawValue, "Classic")
    }
    
    // MARK: - Avatar System Tests
    
    func testAvatarSystemHasAvatars() {
        // When
        let avatars = AvatarSystem.allAvatars
        
        // Then
        XCTAssertGreaterThan(avatars.count, 0, "Avatar system should have avatars")
        XCTAssertGreaterThanOrEqual(avatars.count, 30, "Should have at least 30 avatars")
    }
    
    func testAvatarSystemHasMarvelAvatars() {
        // When
        let marvelAvatars = AvatarSystem.avatars(in: .marvel)
        
        // Then
        XCTAssertGreaterThan(marvelAvatars.count, 0, "Should have Marvel avatars")
        XCTAssertGreaterThanOrEqual(marvelAvatars.count, 5, "Should have at least 5 Marvel avatars")
        
        for avatar in marvelAvatars {
            XCTAssertEqual(avatar.category, .marvel)
        }
    }
    
    func testAvatarSystemHasDCAvatars() {
        // When
        let dcAvatars = AvatarSystem.avatars(in: .dc)
        
        // Then
        XCTAssertGreaterThan(dcAvatars.count, 0, "Should have DC avatars")
        XCTAssertGreaterThanOrEqual(dcAvatars.count, 5, "Should have at least 5 DC avatars")
        
        for avatar in dcAvatars {
            XCTAssertEqual(avatar.category, .dc)
        }
    }
    
    func testAvatarSystemHasCartoonAvatars() {
        // When
        let cartoonAvatars = AvatarSystem.avatars(in: .cartoon)
        
        // Then
        XCTAssertGreaterThan(cartoonAvatars.count, 0, "Should have Cartoon avatars")
        
        for avatar in cartoonAvatars {
            XCTAssertEqual(avatar.category, .cartoon)
        }
    }
    
    func testAvatarSystemHasAnimeAvatars() {
        // When
        let animeAvatars = AvatarSystem.avatars(in: .anime)
        
        // Then
        XCTAssertGreaterThan(animeAvatars.count, 0, "Should have Anime avatars")
        
        for avatar in animeAvatars {
            XCTAssertEqual(avatar.category, .anime)
        }
    }
    
    func testAvatarSystemHasClassicAvatars() {
        // When
        let classicAvatars = AvatarSystem.avatars(in: .classic)
        
        // Then
        XCTAssertGreaterThan(classicAvatars.count, 0, "Should have Classic avatars")
        
        for avatar in classicAvatars {
            XCTAssertEqual(avatar.category, .classic)
        }
    }
    
    func testAvatarSystemAllCategoriesRepresented() {
        // Given
        let allAvatars = AvatarSystem.allAvatars
        let categories = Avatar.AvatarCategory.allCases
        
        // When
        for category in categories {
            let categoryAvatars = allAvatars.filter { $0.category == category }
            
            // Then
            XCTAssertGreaterThan(categoryAvatars.count, 0, "\(category.rawValue) should have avatars")
        }
    }
    
    func testAvatarSystemFindAvatarById() {
        // Given
        let expectedId = "spiderman"
        
        // When
        let avatar = AvatarSystem.avatar(withId: expectedId)
        
        // Then
        XCTAssertNotNil(avatar)
        XCTAssertEqual(avatar?.id, expectedId)
    }
    
    func testAvatarSystemReturnNilForInvalidId() {
        // Given
        let invalidId = "nonexistent-avatar-12345"
        
        // When
        let avatar = AvatarSystem.avatar(withId: invalidId)
        
        // Then
        XCTAssertNil(avatar)
    }
    
    func testAvatarSystemDefaultAvatar() {
        // When
        let defaultAvatar = AvatarSystem.defaultAvatar
        
        // Then
        XCTAssertNotNil(defaultAvatar)
        XCTAssertFalse(defaultAvatar.id.isEmpty)
        XCTAssertFalse(defaultAvatar.name.isEmpty)
        XCTAssertFalse(defaultAvatar.emoji.isEmpty)
    }
    
    func testAvatarSystemDefaultAvatarIsInAllAvatars() {
        // Given
        let defaultAvatar = AvatarSystem.defaultAvatar
        let allAvatars = AvatarSystem.allAvatars
        
        // Then
        XCTAssertTrue(allAvatars.contains(defaultAvatar))
    }
    
    func testAvatarSystemUniqueIds() {
        // Given
        let allAvatars = AvatarSystem.allAvatars
        let ids = allAvatars.map { $0.id }
        let uniqueIds = Set(ids)
        
        // Then
        XCTAssertEqual(ids.count, uniqueIds.count, "All avatar IDs should be unique")
    }
    
    func testAvatarSystemAllAvatarsHaveEmoji() {
        // Given
        let allAvatars = AvatarSystem.allAvatars
        
        // Then
        for avatar in allAvatars {
            XCTAssertFalse(avatar.emoji.isEmpty, "\(avatar.name) should have an emoji")
        }
    }
    
    func testAvatarSystemAllAvatarsHaveName() {
        // Given
        let allAvatars = AvatarSystem.allAvatars
        
        // Then
        for avatar in allAvatars {
            XCTAssertFalse(avatar.name.isEmpty, "Avatar \(avatar.id) should have a name")
        }
    }
    
    func testAvatarSystemSpecificCharacters() {
        // Test for specific popular characters
        let expectedCharacters = [
            "spiderman", "batman", "wednesday", "naruto", "mickey"
        ]
        
        for characterId in expectedCharacters {
            let avatar = AvatarSystem.avatar(withId: characterId)
            XCTAssertNotNil(avatar, "Should have \(characterId)")
        }
    }
    
    // MARK: - Integration Tests
    
    func testAvatarFilterByCategoryReturnsCorrectAvatars() {
        // Given
        let allAvatars = AvatarSystem.allAvatars
        
        for category in Avatar.AvatarCategory.allCases {
            // When
            let filteredAvatars = AvatarSystem.avatars(in: category)
            
            // Then
            XCTAssertEqual(
                filteredAvatars.count,
                allAvatars.filter { $0.category == category }.count,
                "Filter should return same count as manual filter for \(category.rawValue)"
            )
        }
    }
    
    func testAvatarSystemPerformance() {
        // Measure performance of finding avatars
        measure {
            for _ in 0..<1000 {
                _ = AvatarSystem.avatar(withId: "batman")
                _ = AvatarSystem.avatars(in: .marvel)
            }
        }
    }
}
