# CafeMeetup ☕📱🙏

A SwiftUI app for Christian college students to connect over coffee.

![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-MVVM-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🎯 Overview

CafeMeetup is a faith-based social networking app designed specifically for Christian college students to discover and connect with fellow believers over coffee. Built with modern SwiftUI, MVVM architecture, and test-driven development practices.

## ✨ Features

### 👥 User System
- **Multi-Step Registration**: 4-step onboarding process
- **Profile Management**: Personal info, college, location, and coffee preferences
- **Authentication**: Secure email/password sign-up and sign-in
- **Editable Profiles**: Update preferences and bio anytime

### 📝 Community Blog/Feed
- **Create Posts**: Share meetup ideas, study sessions, or coffee chats
- **Tagging System**: Organize posts with tags (Meetup, Study Session, Fellowship, etc.)
- **Social Interactions**: Like and comment on posts
- **Meetup Coordination**: Optional dates and coffee shop associations
- **Real-time Updates**: See the latest posts from your community

### 🗺️ Interactive Map
- **Apple Maps Integration**: Native iOS map experience
- **User Discovery**: See Christian students in your city
- **Location Services**: Real-time location with privacy controls
- **Profile Quick View**: Tap markers to view student profiles
- **Center on Location**: Quickly navigate to your current position

### ☕ Coffee Preferences
- **Favorite Coffee**: Track your preferred coffee type
- **Favorite Shop**: Share your go-to coffee spot
- **Shop Discovery**: Find popular local coffee shops (extensible)
- **Meet-up Locations**: Coordinate gatherings at specific cafés

## 🏗️ Architecture

Built with **MVVM (Model-View-ViewModel)** pattern:

```
Views (SwiftUI) → ViewModels (Business Logic) → Services (Data Layer) → Models (Data)
```

### Key Components

- **Models**: Data structures for User, CoffeeShop, Blog posts, Comments, Likes
- **Views**: SwiftUI views organized by feature (Auth, Blog, Map, Profile)
- **ViewModels**: State management and business logic with Combine
- **Services**: Protocol-based services (Auth, Blog, User, Location)
- **Utilities**: Helpers, validators, constants, extensions

## 🧪 Test-Driven Development

Comprehensive test coverage with **XCTest**:

- ✅ **Model Tests**: Data structure validation
- ✅ **ViewModel Tests**: Business logic and state management
- ✅ **Service Tests**: Mock implementations for async operations
- ✅ **Protocol-Based**: Easy mocking and dependency injection

**Test Statistics:**
- 5 test suites
- 15+ unit tests
- Mock services for all major operations

## 📊 Project Statistics

```
Total Files:        36 files
Swift Code:         26 files
Documentation:      6 guides
Lines of Code:      3,133 lines
Test Coverage:      Models, ViewModels, Services
```

## 🚀 Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Apple Developer Account (for device testing)

### Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/bholsinger09/CafeMeetup.git
   cd CafeMeetup
   ```

2. **Create Xcode Project**
   - Open Xcode
   - File → New → Project
   - Choose iOS → App
   - Save to the cloned directory
   - Follow detailed steps in `QUICKSTART.md`

3. **Add Files**
   - Drag all code folders into Xcode
   - Configure signing
   - Add Info.plist and entitlements

4. **Build & Run**
   ```bash
   # Select iPhone 15 simulator
   Cmd + R
   ```

5. **Run Tests**
   ```bash
   Cmd + U
   ```

### 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Step-by-step setup guide (START HERE!)
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Detailed development guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Architecture diagrams and flows
- **[FILE_TREE.md](FILE_TREE.md)** - Complete file structure
- **[PROJECT_COMPLETE.md](PROJECT_COMPLETE.md)** - Project summary

## 🛠️ Technology Stack

**Frontend:**
- SwiftUI (iOS 16+)
- Combine framework
- MapKit & CoreLocation

**Architecture:**
- MVVM Pattern
- Protocol-Oriented Design
- Dependency Injection

**Testing:**
- XCTest
- Mock Services
- Unit Tests

**Development:**
- Xcode 15+
- Swift 5.9+
- No external dependencies

## 📁 Project Structure

```
CafeMeetup/
├── Models/           # Data models (User, BlogPost, CoffeeShop)
├── Views/            # SwiftUI views
│   ├── Auth/        # Welcome, SignUp, SignIn
│   ├── Blog/        # Feed, CreatePost
│   ├── Map/         # MapView
│   └── Profile/     # Profile, EditProfile
├── ViewModels/      # Business logic
├── Services/        # Data layer (mock implementations)
├── Utilities/       # Helpers and extensions
└── Resources/       # Assets, Info.plist

CafeMeetupTests/     # Unit tests
├── Models/
└── ViewModels/
```

## 🔮 Future Enhancements

### Backend Integration
- [ ] Firebase Authentication
- [ ] Firestore database
- [ ] Cloud Storage for images
- [ ] Push notifications

### Features
- [ ] Direct messaging
- [ ] Calendar integration
- [ ] Photo uploads
- [ ] Coffee shop ratings
- [ ] Search functionality
- [ ] Event creation
- [ ] Group meetups

### UI/UX
- [ ] Dark mode optimization
- [ ] Custom animations
- [ ] Loading states
- [ ] Error handling UI
- [ ] Onboarding tutorial

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow MVVM architecture
2. Write tests for new features
3. Use SwiftUI best practices
4. Update documentation
5. Follow Swift API design guidelines

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for the Christian college student community
- Designed to facilitate meaningful connections over coffee
- Inspired by the need for faith-based social networking

## 📞 Support

- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join community discussions
- **Documentation**: See docs folder for detailed guides

## 🎓 Learning Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [MapKit Documentation](https://developer.apple.com/documentation/mapkit)
- [MVVM Pattern Guide](https://www.objc.io/issues/13-architecture/mvvm/)
- [Swift Testing Guide](https://developer.apple.com/documentation/xctest)

---

**Built with ❤️ and ☕ for Christian college students**

*SwiftUI • MVVM • Test-Driven Development*
