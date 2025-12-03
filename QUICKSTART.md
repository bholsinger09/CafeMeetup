# CafeMeetup - Quick Start Guide

## What You Have Now

Your CafeMeetup project structure is complete with:

✅ **Models** - User, BlogPost, CoffeeShop, Location, Comments, Likes  
✅ **Views** - Welcome, Sign Up/In, Blog Feed, Map, Profile (all in SwiftUI)  
✅ **ViewModels** - Authentication, Blog, Map (MVVM architecture)  
✅ **Services** - Auth, Blog, User, Location (mock services ready)  
✅ **Unit Tests** - Comprehensive tests for models, viewmodels, services  
✅ **Configuration** - Info.plist with location permissions, entitlements

## Next: Create the Xcode Project

Since all the code files are ready, you need to create the Xcode project to tie everything together:

### Step-by-Step Setup

1. **Open Xcode**
   ```
   Launch Xcode 15 or later
   ```

2. **Create New Project**
   - File → New → Project
   - Choose **iOS** → **App**
   - Click **Next**

3. **Configure Project**
   ```
   Product Name: CafeMeetup
   Team: [Select your team]
   Organization Identifier: com.bholsinger (or your preference)
   Bundle Identifier: com.bholsinger.CafeMeetup
   Interface: SwiftUI
   Language: Swift
   Storage: None
   Include Tests: ✓ (checked)
   ```
   - Click **Next**

4. **Save Location**
   - Navigate to: `/Users/benh/Documents/Cafe_Meetup`
   - Click **Create**

5. **Remove Default Files**
   - Delete the auto-generated `ContentView.swift` and `CafeMeetupApp.swift`
   - Keep the Assets.xcassets folder

6. **Add Your Code Files**
   - In Finder, navigate to `/Users/benh/Documents/Cafe_Meetup/CafeMeetup`
   - Drag these folders into Xcode project navigator:
     - Models
     - Views
     - ViewModels
     - Services
     - Utilities
   - Also drag: `CafeMeetupApp.swift` and `ContentView.swift`
   
   - In the dialog that appears:
     - ✓ Check "Copy items if needed"
     - ✓ Select "Create groups"
     - ✓ Add to target: CafeMeetup
     - Click **Finish**

7. **Add Test Files**
   - Drag the contents of `CafeMeetupTests/` folder
   - Add to target: CafeMeetupTests

8. **Configure Info.plist**
   - Select the CafeMeetup target
   - Go to the **Info** tab
   - Right-click in the property list
   - Choose **Raw Keys & Values**
   - Replace with the `Info.plist` file from the project folder
   
   OR manually add:
   - `NSLocationWhenInUseUsageDescription`: "CafeMeetup needs your location to show nearby Christian students and coffee shops on the map."

9. **Add Entitlements**
   - Select CafeMeetup target
   - Go to **Signing & Capabilities**
   - Click **+ Capability**
   - Add **Maps**
   - This should create or update the entitlements file

10. **Configure Signing**
    - In **Signing & Capabilities**
    - Select your **Team**
    - Xcode will automatically manage signing

11. **Build and Run**
    - Select iPhone 15 simulator (or any iOS 16+ simulator)
    - Press **Cmd + B** to build
    - Press **Cmd + R** to run

## Testing Your App

### Run Unit Tests
```
Press Cmd + U
```

This will run all your comprehensive unit tests:
- Model tests
- ViewModel tests
- Service tests

### Manual Testing Flow

1. **Welcome Screen** → Should see "CafeMeetup" with Get Started button
2. **Sign Up** → Multi-step registration:
   - Step 1: Email & Password
   - Step 2: Name & College
   - Step 3: State & City
   - Step 4: Coffee preferences
3. **Main App** → Tab bar with:
   - Feed (blog posts)
   - Map (shows users in your area)
   - Profile (your info)

## Current Functionality

### ✅ Working Now
- User registration (mock)
- Sign in/Sign out
- Create blog posts
- View blog feed
- Like posts
- Map with user markers
- Profile editing
- Location services integration

### 🚧 Using Mock Data
- Authentication (no real backend)
- Blog posts (stored in memory)
- User data (stored in memory)

## Next Steps

### 1. Test with Mock Data
Run the app and test all features. The mock services simulate real API calls with delays.

### 2. Add Backend (Optional)
Choose a backend solution:

**Option A: Firebase** (Recommended for rapid development)
```bash
# Add Firebase SDK via Swift Package Manager
# File → Add Package Dependencies
# URL: https://github.com/firebase/firebase-ios-sdk
```

**Option B: Custom Backend**
- Build REST API (Node.js, Python, Ruby, etc.)
- Replace mock services with URLSession calls

**Option C: Keep Mock Data**
- Great for learning and UI development
- Can add later when needed

### 3. Add Real Coffee Shop Data
Integrate with:
- Yelp API
- Google Places API
- Foursquare API

### 4. Push to GitHub
```bash
cd /Users/benh/Documents/Cafe_Meetup
git init
git add .
git commit -m "Initial CafeMeetup project with MVVM architecture"
git branch -M main
git remote add origin https://github.com/bholsinger09/CafeMeetup.git
git push -u origin main
```

## File Structure Overview

```
CafeMeetup/
├── Models/              # Data structures
│   ├── User.swift      # User model with profile data
│   ├── BlogPost.swift  # Blog posts, comments, likes
│   └── CoffeeShop.swift # Coffee shop data
│
├── Views/              # SwiftUI views (UI layer)
│   ├── Auth/          # Welcome, SignUp, SignIn
│   ├── Blog/          # Feed and CreatePost
│   ├── Map/           # Map with user markers
│   └── Profile/       # Profile viewing and editing
│
├── ViewModels/        # Business logic (MVVM)
│   ├── AuthenticationViewModel.swift
│   ├── BlogViewModel.swift
│   └── MapViewModel.swift
│
├── Services/          # Data layer (mock implementations)
│   ├── AuthenticationService.swift
│   ├── BlogService.swift
│   ├── UserService.swift
│   └── LocationService.swift
│
└── Utilities/         # Helpers
    ├── AppConstants.swift
    ├── DateExtensions.swift
    └── Validator.swift
```

## Architecture: MVVM with SwiftUI

```
View → ObservedObject → ViewModel → Service → Model
       (SwiftUI)        (Logic)     (Data)    (Struct)
```

### Example Flow: Creating a Blog Post
```
1. User taps "Create Post" in BlogFeedView
2. CreatePostView appears
3. User fills form and taps "Post"
4. BlogViewModel.createPost() called
5. BlogService.createPost() called (mock API)
6. New BlogPost model created
7. ViewModel updates @Published posts array
8. View automatically refreshes (SwiftUI)
9. New post appears in feed
```

## Troubleshooting

### Build Errors
```bash
# Clean build
Cmd + Shift + K

# Clean derived data
Cmd + Option + Shift + K

# Restart Xcode
```

### Missing Files
- Make sure all folders were added to the Xcode project
- Check target membership in File Inspector

### Location Not Working
- Simulator: Debug → Location → Custom Location
- Or use a preset like Apple campus

### Tests Failing
- Make sure test files are added to CafeMeetupTests target
- Check @testable import CafeMeetup is present

## Features Overview

### 🙏 Faith-Focused Community
- Designed for Christian college students
- Connect over coffee and faith

### ☕ Coffee Preferences
- Choose favorite coffee type
- Share favorite coffee shops
- Discover new places

### 📍 Location-Based
- See students in your city
- Apple Maps integration
- Meet up nearby

### 📱 Social Features
- Create posts about meetups
- Like and comment
- Share coffee experiences
- Organize study sessions

## Resources

- **DEVELOPMENT.md** - Detailed development guide
- **README.md** - Project overview
- Apple Developer Docs: https://developer.apple.com/documentation/
- SwiftUI Tutorials: https://developer.apple.com/tutorials/swiftui

## Questions?

For help with:
- Architecture questions → See DEVELOPMENT.md
- Adding features → Check the Services layer
- UI changes → Modify Views
- Business logic → Update ViewModels
- Data structure → Edit Models

---

**Ready to build?** Follow the steps above to create your Xcode project and start coding! 🚀☕📱
