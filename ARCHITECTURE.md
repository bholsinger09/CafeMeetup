# CafeMeetup Architecture & Flow Diagrams

## App Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CafeMeetup App                           │
│                      (SwiftUI + MVVM + TDD)                      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          VIEW LAYER                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Auth Views   │  │ Blog Views   │  │  Map Views   │         │
│  │ - Welcome    │  │ - Feed       │  │ - MapView    │         │
│  │ - SignUp     │  │ - CreatePost │  │ - UserDetail │         │
│  │ - SignIn     │  └──────────────┘  └──────────────┘         │
│  └──────────────┘                                                │
│  ┌──────────────┐                                                │
│  │Profile Views │                                                │
│  │ - Profile    │                                                │
│  │ - EditProfile│                                                │
│  └──────────────┘                                                │
└───────────────────────────┬─────────────────────────────────────┘
                            │ @ObservedObject / @Published
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      VIEWMODEL LAYER                             │
│  ┌────────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │ Authentication     │  │ Blog           │  │ Map          │  │
│  │ ViewModel          │  │ ViewModel      │  │ ViewModel    │  │
│  │                    │  │                │  │              │  │
│  │ - isAuthenticated  │  │ - posts[]      │  │ - users[]    │  │
│  │ - currentUser      │  │ - isLoading    │  │ - region     │  │
│  │ - signUp()         │  │ - createPost() │  │ - fetchUsers│  │
│  │ - signIn()         │  │ - likePost()   │  │ - center()   │  │
│  └────────────────────┘  └────────────────┘  └──────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │ async/await calls
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                       SERVICE LAYER                              │
│  ┌────────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │ Authentication │  │ Blog         │  │ User               │  │
│  │ Service        │  │ Service      │  │ Service            │  │
│  │                │  │              │  │                    │  │
│  │ - signUp()     │  │ - fetchPosts │  │ - fetchUsers()     │  │
│  │ - signIn()     │  │ - createPost │  │ - searchUsers()    │  │
│  │ - signOut()    │  │ - likePost   │  └────────────────────┘  │
│  └────────────────┘  └──────────────┘                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Location Service (CLLocationManager)                      │  │
│  │ - requestAuthorization()                                  │  │
│  │ - getCurrentLocation()                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │ Data operations
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                        MODEL LAYER                               │
│  ┌──────────┐  ┌────────────┐  ┌─────────────┐  ┌──────────┐  │
│  │  User    │  │  BlogPost  │  │ CoffeeShop  │  │ Location │  │
│  │          │  │            │  │             │  │          │  │
│  │ - id     │  │ - id       │  │ - id        │  │ - lat    │  │
│  │ - name   │  │ - title    │  │ - name      │  │ - lng    │  │
│  │ - email  │  │ - content  │  │ - address   │  └──────────┘  │
│  │ - college│  │ - author   │  │ - location  │                │
│  │ - state  │  │ - tags     │  └─────────────┘                │
│  │ - city   │  │ - likes    │                                  │
│  └──────────┘  └────────────┘  ┌──────────┐  ┌──────────┐    │
│                                 │ Comment  │  │   Like   │    │
│                                 └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## User Flow Diagram

```
                    ┌─────────────────┐
                    │   App Launch    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Check Auth      │
                    │ Status          │
                    └────────┬────────┘
                             │
                ┏━━━━━━━━━━━━┻━━━━━━━━━━━━┓
                ▼                          ▼
        ┌───────────────┐          ┌──────────────┐
        │ Not Auth      │          │ Authenticated│
        │ WelcomeView   │          │ MainTabView  │
        └───────┬───────┘          └──────┬───────┘
                │                          │
     ┌──────────┼──────────┐              │
     ▼                     ▼              │
┌──────────┐        ┌──────────┐         │
│ Sign Up  │        │ Sign In  │         │
└────┬─────┘        └────┬─────┘         │
     │                   │                │
     └───────┬───────────┘                │
             ▼                            ▼
        ┌─────────────────────────────────────────┐
        │          Main App Interface             │
        │  ┌──────────────────────────────────┐  │
        │  │         Tab Bar                   │  │
        │  ├──────────┬─────────┬─────────────┤  │
        │  │   Feed   │   Map   │   Profile   │  │
        │  └──────────┴─────────┴─────────────┘  │
        └─────────────────────────────────────────┘
                      │
          ┏━━━━━━━━━━━╋━━━━━━━━━━━┓
          ▼           ▼            ▼
    ┌──────────┐ ┌─────────┐ ┌───────────┐
    │Blog Feed │ │Map View │ │Profile    │
    │          │ │         │ │           │
    │- Posts   │ │- Users  │ │- Info     │
    │- Like    │ │- Markers│ │- Edit     │
    │- Comment │ │- Details│ │- Sign Out │
    └────┬─────┘ └────┬────┘ └───────────┘
         │            │
         ▼            ▼
    ┌──────────┐ ┌─────────┐
    │Create    │ │User     │
    │Post      │ │Profile  │
    └──────────┘ └─────────┘
```

## Feature Flow: Creating a Blog Post

```
User                BlogFeedView         CreatePostView        BlogViewModel        BlogService        Model
 │                       │                     │                     │                   │              │
 │  Tap "+" Button      │                     │                     │                   │              │
 │──────────────────────>│                     │                     │                   │              │
 │                       │                     │                     │                   │              │
 │                       │  Present Sheet      │                     │                   │              │
 │                       │────────────────────>│                     │                   │              │
 │                       │                     │                     │                   │              │
 │  Fill Form            │                     │                     │                   │              │
 │──────────────────────────────────────────>│                     │                   │              │
 │                       │                     │                     │                   │              │
 │  Tap "Post"          │                     │                     │                   │              │
 │──────────────────────────────────────────>│                     │                   │              │
 │                       │                     │                     │                   │              │
 │                       │                     │  createPost()       │                   │              │
 │                       │                     │────────────────────>│                   │              │
 │                       │                     │                     │                   │              │
 │                       │                     │                     │  createPost()     │              │
 │                       │                     │                     │──────────────────>│              │
 │                       │                     │                     │                   │              │
 │                       │                     │                     │                   │ BlogPost     │
 │                       │                     │                     │                   │─────────────>│
 │                       │                     │                     │                   │              │
 │                       │                     │                     │    Return Post    │              │
 │                       │                     │                     │<──────────────────│              │
 │                       │                     │                     │                   │              │
 │                       │                     │   Update @Published │                   │              │
 │                       │                     │      posts array    │                   │              │
 │                       │                     │<────────────────────│                   │              │
 │                       │                     │                     │                   │              │
 │                       │  Dismiss Sheet      │                     │                   │              │
 │                       │<────────────────────│                     │                   │              │
 │                       │                     │                     │                   │              │
 │                       │ View Auto-Updates   │                     │                   │              │
 │<──────────────────────│ (SwiftUI Binding)   │                     │                   │              │
 │                       │                     │                     │                   │              │
 │  See New Post         │                     │                     │                   │              │
 │<──────────────────────│                     │                     │                   │              │
```

## Data Flow: User Authentication

```
┌──────────────────────────────────────────────────────────────┐
│                      SIGN UP FLOW                            │
└──────────────────────────────────────────────────────────────┘

SignUpView
    │
    │ User fills 4-step form:
    │ 1. Email & Password
    │ 2. Name & College
    │ 3. State & City
    │ 4. Coffee Preferences
    │
    ▼
AuthenticationViewModel.signUp()
    │
    │ Creates User model with data
    │
    ▼
AuthenticationService.signUp()
    │
    │ Validates password (min 6 chars)
    │ Checks if email exists
    │ Stores user (mock)
    │
    ▼
Updates ViewModel:
    │
    ├─> currentUser = new User
    ├─> isAuthenticated = true
    └─> errorMessage = nil
        │
        ▼
ContentView observes change
    │
    ▼
Shows MainTabView (user is authenticated)


┌──────────────────────────────────────────────────────────────┐
│                      SIGN IN FLOW                            │
└──────────────────────────────────────────────────────────────┘

SignInView
    │
    │ User enters email & password
    │
    ▼
AuthenticationViewModel.signIn()
    │
    ▼
AuthenticationService.signIn()
    │
    │ Validates credentials
    │ Retrieves user data
    │
    ▼
Updates ViewModel:
    │
    ├─> currentUser = existing User
    ├─> isAuthenticated = true
    └─> errorMessage = nil
        │
        ▼
ContentView observes change
    │
    ▼
Shows MainTabView
```

## Map Integration Flow

```
┌──────────────────────────────────────────────────────────────┐
│                     MAP VIEW FLOW                            │
└──────────────────────────────────────────────────────────────┘

MapView appears
    │
    ├─> Request location permission
    │   LocationService.requestAuthorization()
    │
    └─> Fetch nearby users
        │
        ▼
MapViewModel.fetchNearbyUsers(city, state)
    │
    ▼
UserService.fetchUsers(city, state)
    │
    │ Returns users in same city/state
    │
    ▼
MapViewModel updates:
    │
    ├─> users = [User]
    ├─> region = centered on first user
    └─> isLoading = false
        │
        ▼
Map displays user markers
    │
    │ User taps marker
    │
    ▼
Show UserDetailSheet
    │
    ├─> Display profile info
    ├─> Coffee preferences
    └─> Connect button
```

## Test-Driven Development Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    TDD WORKFLOW                              │
└──────────────────────────────────────────────────────────────┘

1. Write Test (Red)
   │
   │ Create test case
   │ Define expected behavior
   │ Test fails (no implementation)
   │
   ▼
2. Write Code (Green)
   │
   │ Implement minimal code
   │ Make test pass
   │
   ▼
3. Refactor (Refactor)
   │
   │ Improve code quality
   │ Ensure tests still pass
   │
   ▼
4. Repeat for next feature


Example: User Model Test

Test:
┌─────────────────────────────────────┐
│ testUserInitialization()            │
│   - Create user with data           │
│   - Assert all fields match         │
│   - Test passes ✓                   │
└─────────────────────────────────────┘

Implementation:
┌─────────────────────────────────────┐
│ struct User {                       │
│   let id: String                    │
│   var email: String                 │
│   var fullName: String              │
│   // ... other fields               │
│ }                                   │
└─────────────────────────────────────┘
```

## Project Structure with Dependencies

```
CafeMeetup (iOS App)
│
├── Views (SwiftUI)
│   │
│   ├── Depends on: ViewModels (@ObservedObject)
│   └── Uses: Models (for display)
│
├── ViewModels
│   │
│   ├── Depends on: Services (protocol injection)
│   └── Uses: Models (data structures)
│
├── Services
│   │
│   ├── Implements: Protocols
│   ├── Returns: Models
│   └── External: CoreLocation, MapKit
│
├── Models (Pure Data)
│   │
│   └── No dependencies (Codable, Equatable)
│
└── Utilities (Helpers)
    │
    └── Used by: All layers

Dependency Direction: Views → ViewModels → Services → Models
                       ↑ All layers can use Utilities ↑
```

## State Management

```
┌──────────────────────────────────────────────────────────────┐
│                  SWIFTUI STATE FLOW                          │
└──────────────────────────────────────────────────────────────┘

ViewModel (@Published property changes)
    │
    │ Example: posts array updated
    │
    ▼
ObservableObject protocol notifies subscribers
    │
    ▼
View (@ObservedObject or @EnvironmentObject)
    │
    │ SwiftUI automatically detects change
    │
    ▼
View body recomputes
    │
    ▼
UI updates automatically
    │
    └─> No manual refresh needed!


State Types in CafeMeetup:

@StateObject
  └─> Create ViewModel instance
      (MainTabView creates ViewModels)

@ObservedObject
  └─> Pass ViewModel to child views
      (BlogFeedView observes BlogViewModel)

@EnvironmentObject
  └─> Share across view hierarchy
      (AuthenticationViewModel)

@State
  └─> Local view state
      (Form fields, toggles)

@Binding
  └─> Two-way binding
      (Pass to child views)
```
