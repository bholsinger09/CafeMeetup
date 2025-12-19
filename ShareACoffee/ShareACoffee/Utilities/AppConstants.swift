import Foundation

enum AppConstants {
    // App Information
    static let appName = "ShareACoffee"
    static let version = "1.0.0"
    
    // Map Settings
    static let defaultLatitude = 37.7749
    static let defaultLongitude = -122.4194
    static let mapZoomLevel = 0.1
    
    // Pagination
    static let postsPerPage = 20
    static let usersPerPage = 50
    
    // Coffee Types
    static let popularCoffeeTypes = [
        "Latte",
        "Cappuccino",
        "Americano",
        "Espresso",
        "Mocha",
        "Cold Brew",
        "Macchiato",
        "Flat White",
        "Cortado",
        "Pour Over"
    ]
    
    // Popular Coffee Shops
    static let popularCoffeeShops = [
        "Starbucks",
        "Peet's Coffee",
        "Dutch Bros",
        "The Coffee Bean & Tea Leaf",
        "Dunkin'",
        "Caribou Coffee",
        "Local Independent Café",
        "Other"
    ]
    
    // US States
    static let usStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California",
        "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
        "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
        "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
        "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
        "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
        "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
        "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]
}
