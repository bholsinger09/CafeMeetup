import SwiftUI

struct Avatar: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let category: AvatarCategory
    
    enum AvatarCategory: String, Codable, CaseIterable {
        case animals = "Animals"
        case nature = "Nature"
        case food = "Food & Drink"
        case activities = "Activities"
        case symbols = "Symbols"
        case people = "People"
    }
}

struct AvatarSystem {
    static let allAvatars: [Avatar] = [
        // Animals
        Avatar(id: "cat", name: "Cat", emoji: "🐱", category: .animals),
        Avatar(id: "dog", name: "Dog", emoji: "🐕", category: .animals),
        Avatar(id: "fox", name: "Fox", emoji: "🦊", category: .animals),
        Avatar(id: "lion", name: "Lion", emoji: "🦁", category: .animals),
        Avatar(id: "tiger", name: "Tiger", emoji: "🐯", category: .animals),
        Avatar(id: "bear", name: "Bear", emoji: "🐻", category: .animals),
        Avatar(id: "panda", name: "Panda", emoji: "🐼", category: .animals),
        Avatar(id: "koala", name: "Koala", emoji: "🐨", category: .animals),
        Avatar(id: "wolf", name: "Wolf", emoji: "🐺", category: .animals),
        Avatar(id: "owl", name: "Owl", emoji: "🦉", category: .animals),
        Avatar(id: "eagle", name: "Eagle", emoji: "🦅", category: .animals),
        Avatar(id: "penguin", name: "Penguin", emoji: "🐧", category: .animals),
        Avatar(id: "dolphin", name: "Dolphin", emoji: "🐬", category: .animals),
        Avatar(id: "turtle", name: "Turtle", emoji: "🐢", category: .animals),
        Avatar(id: "butterfly", name: "Butterfly", emoji: "🦋", category: .animals),
        
        // Nature
        Avatar(id: "sunflower", name: "Sunflower", emoji: "🌻", category: .nature),
        Avatar(id: "rose", name: "Rose", emoji: "🌹", category: .nature),
        Avatar(id: "tree", name: "Tree", emoji: "🌳", category: .nature),
        Avatar(id: "cactus", name: "Cactus", emoji: "🌵", category: .nature),
        Avatar(id: "moon", name: "Moon", emoji: "🌙", category: .nature),
        Avatar(id: "star", name: "Star", emoji: "⭐", category: .nature),
        Avatar(id: "sun", name: "Sun", emoji: "☀️", category: .nature),
        Avatar(id: "cloud", name: "Cloud", emoji: "☁️", category: .nature),
        Avatar(id: "rainbow", name: "Rainbow", emoji: "🌈", category: .nature),
        Avatar(id: "mountain", name: "Mountain", emoji: "⛰️", category: .nature),
        Avatar(id: "wave", name: "Wave", emoji: "🌊", category: .nature),
        Avatar(id: "fire", name: "Fire", emoji: "🔥", category: .nature),
        Avatar(id: "snowflake", name: "Snowflake", emoji: "❄️", category: .nature),
        Avatar(id: "lightning", name: "Lightning", emoji: "⚡", category: .nature),
        
        // Food & Drink
        Avatar(id: "coffee", name: "Coffee", emoji: "☕", category: .food),
        Avatar(id: "pizza", name: "Pizza", emoji: "🍕", category: .food),
        Avatar(id: "burger", name: "Burger", emoji: "🍔", category: .food),
        Avatar(id: "taco", name: "Taco", emoji: "🌮", category: .food),
        Avatar(id: "sushi", name: "Sushi", emoji: "🍣", category: .food),
        Avatar(id: "ramen", name: "Ramen", emoji: "🍜", category: .food),
        Avatar(id: "donut", name: "Donut", emoji: "🍩", category: .food),
        Avatar(id: "cupcake", name: "Cupcake", emoji: "🧁", category: .food),
        Avatar(id: "icecream", name: "Ice Cream", emoji: "🍦", category: .food),
        Avatar(id: "strawberry", name: "Strawberry", emoji: "🍓", category: .food),
        Avatar(id: "avocado", name: "Avocado", emoji: "🥑", category: .food),
        Avatar(id: "cookie", name: "Cookie", emoji: "🍪", category: .food),
        
        // Activities
        Avatar(id: "book", name: "Book", emoji: "📚", category: .activities),
        Avatar(id: "graduation", name: "Graduation", emoji: "🎓", category: .activities),
        Avatar(id: "pencil", name: "Pencil", emoji: "✏️", category: .activities),
        Avatar(id: "laptop", name: "Laptop", emoji: "💻", category: .activities),
        Avatar(id: "music", name: "Music", emoji: "🎵", category: .activities),
        Avatar(id: "guitar", name: "Guitar", emoji: "🎸", category: .activities),
        Avatar(id: "art", name: "Art", emoji: "🎨", category: .activities),
        Avatar(id: "camera", name: "Camera", emoji: "📷", category: .activities),
        Avatar(id: "soccer", name: "Soccer", emoji: "⚽", category: .activities),
        Avatar(id: "basketball", name: "Basketball", emoji: "🏀", category: .activities),
        Avatar(id: "tennis", name: "Tennis", emoji: "🎾", category: .activities),
        Avatar(id: "gaming", name: "Gaming", emoji: "🎮", category: .activities),
        
        // Symbols
        Avatar(id: "heart", name: "Heart", emoji: "❤️", category: .symbols),
        Avatar(id: "sparkles", name: "Sparkles", emoji: "✨", category: .symbols),
        Avatar(id: "crown", name: "Crown", emoji: "👑", category: .symbols),
        Avatar(id: "gem", name: "Gem", emoji: "💎", category: .symbols),
        Avatar(id: "rocket", name: "Rocket", emoji: "🚀", category: .symbols),
        Avatar(id: "trophy", name: "Trophy", emoji: "🏆", category: .symbols),
        Avatar(id: "medal", name: "Medal", emoji: "🏅", category: .symbols),
        Avatar(id: "bulb", name: "Light Bulb", emoji: "💡", category: .symbols),
        Avatar(id: "peace", name: "Peace", emoji: "✌️", category: .symbols),
        Avatar(id: "thumbsup", name: "Thumbs Up", emoji: "👍", category: .symbols),
        
        // People
        Avatar(id: "scientist", name: "Scientist", emoji: "🧑‍🔬", category: .people),
        Avatar(id: "artist", name: "Artist", emoji: "🧑‍🎨", category: .people),
        Avatar(id: "teacher", name: "Teacher", emoji: "🧑‍🏫", category: .people),
        Avatar(id: "student", name: "Student", emoji: "🧑‍🎓", category: .people),
        Avatar(id: "chef", name: "Chef", emoji: "🧑‍🍳", category: .people),
        Avatar(id: "astronaut", name: "Astronaut", emoji: "🧑‍🚀", category: .people),
        Avatar(id: "doctor", name: "Doctor", emoji: "🧑‍⚕️", category: .people),
        Avatar(id: "engineer", name: "Engineer", emoji: "🧑‍💻", category: .people),
        Avatar(id: "musician", name: "Musician", emoji: "🧑‍🎤", category: .people),
        Avatar(id: "athlete", name: "Athlete", emoji: "🧑‍🦱", category: .people),
    ]
    
    static func avatar(withId id: String) -> Avatar? {
        allAvatars.first { $0.id == id }
    }
    
    static func avatars(in category: Avatar.AvatarCategory) -> [Avatar] {
        allAvatars.filter { $0.category == category }
    }
    
    static var defaultAvatar: Avatar {
        allAvatars[0] // Cat as default
    }
}
