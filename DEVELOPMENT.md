# CafeMeetup Development Guide

## Project Setup

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Apple Developer Account (for device testing with location services)

### Initial Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/bholsinger09/CafeMeetup.git
   cd CafeMeetup
   ```

2. **Open in Xcode**
   - Double-click `CafeMeetup.xcodeproj` (you'll need to create this in Xcode)
   - Or open from command line: `open CafeMeetup.xcodeproj`

3. **Configure Signing**
   - Select the CafeMeetup target
   - Go to Signing & Capabilities
   - Select your Team
   - Update Bundle Identifier if needed

### Creating the Xcode Project

Since the code files are ready, you need to create the Xcode project:

1. Open Xcode
2. Create a new project: File → New → Project
3. Select iOS → App
4. Configure:
   - Product Name: `CafeMeetup`
   - Team: Your team
   - Organization Identifier: `com.yourname` (or your preference)
   - Bundle Identifier: `com.yourname.CafeMeetup`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
   - Include Tests: Yes
5. Save to: `/Users/benh/Documents/Cafe_Meetup`

6. **Add Files to Project**
   - Delete the default ContentView.swift and CafeMeetupApp.swift created by Xcode
   - Drag all folders (Models, Views, ViewModels, Services, Utilities) into the project
   - Make sure "Copy items if needed" is checked
   - Select "Create groups"
   - Add to both CafeMeetup and CafeMeetupTests targets as appropriate

7. **Add Info.plist**
   - Replace the default Info.plist with the one provided
   - Add the CafeMeetup.entitlements file to the project

8. **Configure Build Settings**
   - Select the project in Navigator
   - Select CafeMeetup target
   - Go to "Signing & Capabilities"
   - Add "Maps" capability
   - Ensure Code Signing Entitlements points to `CafeMeetup.entitlements`

## Architecture Overview

### MVVM Pattern

The app follows the Model-View-ViewModel (MVVM) architecture:

```
┌─────────────────────────────────────────────────┐
│                    Views                         │
│  (SwiftUI Views - UI Layer)                     │
│  - WelcomeView, SignUpView, BlogFeedView, etc.  │
└─────────────────┬───────────────────────────────┘
                  │ @Published/@ObservedObject
                  ↓
┌─────────────────────────────────────────────────┐
│                ViewModels                        │
│  (Business Logic & State Management)            │
│  - AuthenticationViewModel                       │
│  - BlogViewModel                                 │
│  - MapViewModel                                  │
└─────────────────┬───────────────────────────────┘
                  │ Async/Await calls
                  ↓
┌─────────────────────────────────────────────────┐
│                 Services                         │
│  (Data Layer - API, Auth, Location)             │
│  - AuthenticationService                         │
│  - BlogService                                   │
│  - UserService                                   │
│  - LocationService                               │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│                  Models                          │
│  (Data Structures)                               │
│  - User, BlogPost, CoffeeShop, etc.             │
└─────────────────────────────────────────────────┘
```

### Folder Structure

```
CafeMeetup/
├── CafeMeetupApp.swift          # App entry point
├── ContentView.swift             # Root view with auth logic
├── Models/                       # Data models
│   ├── User.swift
│   ├── BlogPost.swift
│   └── CoffeeShop.swift
├── Views/                        # SwiftUI views
│   ├── Auth/
│   │   ├── WelcomeView.swift
│   │   ├── SignUpView.swift
│   │   └── SignInView.swift
│   ├── Blog/
│   │   ├── BlogFeedView.swift
│   │   └── CreatePostView.swift
│   ├── Map/
│   │   └── MapView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── EditProfileView.swift
│   └── MainTabView.swift
├── ViewModels/                   # ViewModels
│   ├── AuthenticationViewModel.swift
│   ├── BlogViewModel.swift
│   └── MapViewModel.swift
├── Services/                     # Services layer
│   ├── AuthenticationService.swift
│   ├── BlogService.swift
│   ├── UserService.swift
│   └── LocationService.swift
├── Utilities/                    # Helper functions
│   ├── AppConstants.swift
│   ├── DateExtensions.swift
│   └── Validator.swift
├── Resources/                    # Assets, etc.
├── Info.plist
└── CafeMeetup.entitlements

CafeMeetupTests/
├── Models/                       # Model tests
├── ViewModels/                   # ViewModel tests
└── Services/                     # Service tests
```

## Test-Driven Development

### Running Tests

Run all tests:
```bash
# From Xcode
Cmd + U

# From command line
xcodebuild test -scheme CafeMeetup -destination 'platform=iOS Simulator,name=iPhone 15'
```

Run specific test:
```bash
xcodebuild test -scheme CafeMeetup -only-testing:CafeMeetupTests/UserModelTests
```

### Test Structure

Each layer has corresponding tests:
- **Model Tests**: Verify data structures and initialization
- **ViewModel Tests**: Test business logic and state management
- **Service Tests**: Mock API calls and data operations

### Writing New Tests

Example test pattern:
```swift
import XCTest
@testable import CafeMeetup

final class MyFeatureTests: XCTestCase {
    var viewModel: MyViewModel!
    var mockService: MockService!
    
    override func setUp() {
        super.setUp()
        mockService = MockService()
        viewModel = MyViewModel(service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testMyFeature() async {
        // Given
        // When
        // Then
    }
}
```

## Key Features

### 1. Authentication
- Email/password sign up and sign in
- Multi-step registration form
- Profile management
- Sign out functionality

### 2. User Profile
- Personal information
- Coffee preferences
- Location (city/state)
- College/university
- Bio

### 3. Blog/Feed
- Create posts about meetups
- Tag posts (Meetup, Coffee Chat, Study Session, etc.)
- Like and comment on posts
- View posts from nearby students
- Optional meetup date and coffee shop

### 4. Map View
- Apple Maps integration
- See nearby Christian students
- User location markers
- Tap markers to view profiles
- Center on current location

### 5. Coffee Shop Integration
- Favorite coffee preferences
- Favorite coffee shop
- Coffee shop locations on map (future)
- Meetup coordination at specific shops

## Mock Data vs. Real Backend

Currently, the app uses **mock services** for development and testing:

- `AuthenticationService`: Mock user authentication
- `BlogService`: Mock blog posts and comments
- `UserService`: Mock user data
- `LocationService`: Real iOS location services

### Integrating a Real Backend

To integrate Firebase, AWS, or a custom backend:

1. **Replace Service Implementations**
   - Keep the protocol interfaces (e.g., `AuthenticationServiceProtocol`)
   - Implement real networking code
   - Use URLSession, Firebase SDK, or third-party libraries

2. **Example: Firebase Integration**
   ```swift
   import Firebase
   import FirebaseAuth
   
   class FirebaseAuthenticationService: AuthenticationServiceProtocol {
       func signUp(email: String, password: String, user: User) async throws -> User {
           let result = try await Auth.auth().createUser(withEmail: email, password: password)
           // Store user data in Firestore
           try await Firestore.firestore()
               .collection("users")
               .document(result.user.uid)
               .setData(user.dictionary)
           return user
       }
       // ... implement other methods
   }
   ```

3. **Update ViewModels**
   ```swift
   init(authService: AuthenticationServiceProtocol = FirebaseAuthenticationService.shared) {
       self.authService = authService
   }
   ```

## Location Services

### Setup
1. Location permissions are defined in `Info.plist`
2. `LocationService` manages CLLocationManager
3. Request permission on first use

### Usage
```swift
// Request permission
locationService.requestAuthorization()

// Get current location
let coordinate = try await locationService.getCurrentLocation()

// Continuous updates
locationService.startUpdatingLocation()
```

## Building and Running

### Simulator
1. Select an iOS simulator (iPhone 15 recommended)
2. Press Cmd + R or click Play button
3. For location testing: Debug → Simulate Location

### Physical Device
1. Connect device via USB
2. Select device in Xcode
3. Build and run (Cmd + R)
4. Grant location permissions when prompted

## Common Issues

### Location Services Not Working
- Ensure Info.plist has location usage descriptions
- Check location permissions in Settings
- Simulator: Use Debug → Simulate Location

### Build Errors
- Clean build folder: Cmd + Shift + K
- Derived data: Cmd + Option + Shift + K
- Restart Xcode

### Signing Issues
- Verify Team is selected
- Check Bundle Identifier is unique
- Ensure Maps capability is added

## Next Steps

### Recommended Enhancements
1. **Backend Integration**
   - Firebase Authentication
   - Firestore for data storage
   - Cloud Functions for serverless logic

2. **Features**
   - Direct messaging between users
   - Push notifications for meetups
   - Calendar integration
   - Coffee shop database (Yelp/Google Places API)
   - Image uploads for profiles and posts
   - Search functionality

3. **UI/UX**
   - Custom coffee-themed design
   - Dark mode support
   - Animations and transitions
   - Accessibility improvements

4. **Testing**
   - UI tests with XCUITest
   - Integration tests
   - Performance testing

5. **Deployment**
   - App Store submission
   - TestFlight beta testing
   - App Store Connect setup

## Contributing

When contributing to this project:
1. Follow MVVM architecture
2. Write tests for new features
3. Use SwiftUI best practices
4. Follow Swift API design guidelines
5. Update documentation

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [MapKit Documentation](https://developer.apple.com/documentation/mapkit)
- [Core Location Documentation](https://developer.apple.com/documentation/corelocation)
- [Swift Testing Guide](https://developer.apple.com/documentation/xctest)
- [MVVM Pattern](https://www.objc.io/issues/13-architecture/mvvm/)

## License

MIT License - See LICENSE file for details
