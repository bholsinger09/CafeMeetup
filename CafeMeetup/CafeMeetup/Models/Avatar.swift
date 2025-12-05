import SwiftUI

struct Avatar: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let category: AvatarCategory
    
    enum AvatarCategory: String, Codable, CaseIterable {
        case marvel = "Marvel"
        case dc = "DC"
        case cartoon = "Cartoon"
        case anime = "Anime"
        case classic = "Classic"
    }
}

struct AvatarSystem {
    static let allAvatars: [Avatar] = [
        // Marvel Characters
        Avatar(id: "spiderman", name: "Spider-Man", emoji: "🕷️", category: .marvel),
        Avatar(id: "ironman", name: "Iron Man", emoji: "🦾", category: .marvel),
        Avatar(id: "hulk", name: "Hulk", emoji: "💚", category: .marvel),
        Avatar(id: "captain", name: "Captain America", emoji: "🛡️", category: .marvel),
        Avatar(id: "thor", name: "Thor", emoji: "⚡", category: .marvel),
        Avatar(id: "blackpanther", name: "Black Panther", emoji: "🐾", category: .marvel),
        Avatar(id: "widow", name: "Black Widow", emoji: "🕸️", category: .marvel),
        Avatar(id: "strange", name: "Dr. Strange", emoji: "🔮", category: .marvel),
        
        // DC Characters
        Avatar(id: "batman", name: "Batman", emoji: "🦇", category: .dc),
        Avatar(id: "superman", name: "Superman", emoji: "🦸", category: .dc),
        Avatar(id: "wonderwoman", name: "Wonder Woman", emoji: "👸", category: .dc),
        Avatar(id: "flash", name: "The Flash", emoji: "⚡", category: .dc),
        Avatar(id: "aquaman", name: "Aquaman", emoji: "🔱", category: .dc),
        Avatar(id: "joker", name: "Joker", emoji: "🃏", category: .dc),
        Avatar(id: "harley", name: "Harley Quinn", emoji: "🎪", category: .dc),
        
        // Cartoon Characters
        Avatar(id: "wednesday", name: "Wednesday Addams", emoji: "🖤", category: .cartoon),
        Avatar(id: "snoopy", name: "Snoopy", emoji: "🐕", category: .cartoon),
        Avatar(id: "garfield", name: "Garfield", emoji: "🐱", category: .cartoon),
        Avatar(id: "scooby", name: "Scooby-Doo", emoji: "🦴", category: .cartoon),
        Avatar(id: "bugs", name: "Bugs Bunny", emoji: "🐰", category: .cartoon),
        Avatar(id: "tweety", name: "Tweety", emoji: "🐤", category: .cartoon),
        Avatar(id: "pikachu", name: "Pikachu", emoji: "⚡", category: .cartoon),
        
        // Anime Characters
        Avatar(id: "naruto", name: "Naruto", emoji: "🍜", category: .anime),
        Avatar(id: "goku", name: "Goku", emoji: "🥋", category: .anime),
        Avatar(id: "luffy", name: "Luffy", emoji: "🏴‍☠️", category: .anime),
        Avatar(id: "sailor", name: "Sailor Moon", emoji: "🌙", category: .anime),
        Avatar(id: "totoro", name: "Totoro", emoji: "🌳", category: .anime),
        
        // Classic Characters
        Avatar(id: "mickey", name: "Mickey Mouse", emoji: "🐭", category: .classic),
        Avatar(id: "minnie", name: "Minnie Mouse", emoji: "🎀", category: .classic),
        Avatar(id: "pooh", name: "Winnie the Pooh", emoji: "🍯", category: .classic),
        Avatar(id: "simba", name: "Simba", emoji: "🦁", category: .classic),
        Avatar(id: "elsa", name: "Elsa", emoji: "❄️", category: .classic),
        Avatar(id: "stitch", name: "Stitch", emoji: "👾", category: .classic),
    ]
    
    static func avatar(withId id: String) -> Avatar? {
        allAvatars.first { $0.id == id }
    }
    
    static func avatars(in category: Avatar.AvatarCategory) -> [Avatar] {
        allAvatars.filter { $0.category == category }
    }
    
    static var defaultAvatar: Avatar {
        allAvatars[0] // Spider-Man as default
    }
}
