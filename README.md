# LatteLink ☕📚

An iOS app for college students to organize group study sessions at coffee shops.

![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-MVVM-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🎯 Overview

LatteLink is an academic productivity app designed for college students to organize and join GROUP STUDY SESSIONS (3+ people) at local coffee shops. This is NOT a dating app—it's focused exclusively on collaborative group learning organized by course codes.

## ✨ Features

### 📚 Group Study Sessions
- **Course-Based Organization**: Find sessions by specific course codes (CS 101, CALC 2, etc.)
- **Group Requirements**: All sessions require 3+ students (no one-on-one meetups)
- **Session Creation**: Organize study groups for your classes at coffee shops
- **Join Sessions**: Browse and join existing study groups in your courses
- **Check-In System**: Verify attendance at coffee shop study sessions

### 🎓 Academic Progress
- **Course Management**: Track your current classes and schedule
- **Study Tracking**: Monitor sessions attended and participation
- **Badge System**: Earn 50+ achievement badges for study streaks
- **Progress Dashboard**: View your academic collaboration metrics
- **Study Streaks**: Build consistency with regular group study

### 🗺️ Coffee Shop Discovery
- **Interactive Map**: Find study-friendly cafés with wifi and quiet areas
- **Session Locations**: See where study groups are meeting
- **Venue Details**: Get info about coffee shops (wifi, outlets, noise level)
- **Directions**: Navigate to your study session location
- **Location Services**: Find coffee shops near campus

### 📝 Academic Blog
- **Study Tips**: Share exam prep strategies and course advice
- **Course Reviews**: Help classmates choose classes
- **Meetup Coordination**: Organize recurring study groups
- **Resource Sharing**: Post helpful materials and study guides
- **Tag System**: Organize content by course, topic, or exam

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
