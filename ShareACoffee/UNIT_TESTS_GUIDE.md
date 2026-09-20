# Unit Tests Guide for ShareACoffee Modular Architecture

## Overview
Each package has been equipped with unit tests to verify:
- ✅ All syntax is correct
- ✅ All types are in scope
- ✅ All imports are properly configured
- ✅ Service singletons are accessible
- ✅ Model initialization works correctly

## Packages with Tests

### 1. **ShareACoffeeCore Tests**
Tests for foundation models and utilities:
- User, Avatar, Course, Achievement models
- AppTheme and color management
- Location model
- ThemeManager functionality

**Test File:** `ShareACoffeeCore/Tests/ShareACoffeeCoreTests/ShareACoffeeCoreTests.swift`

### 2. **ShareACoffeeAuth Tests**
Tests for authentication functionality:
- AuthenticationViewModel initialization
- AuthenticationService singleton access

**Test File:** `ShareACoffeeAuth/Tests/ShareACoffeeAuthTests/ShareACoffeeAuthTests.swift`

### 3. **ShareACoffeeSocial Tests**
Tests for social features:
- Match and Message models
- MatchService and MessageService singletons

**Test File:** `ShareACoffeeSocial/Tests/ShareACoffeeSocialTests/ShareACoffeeSocialTests.swift`

### 4. **ShareACoffeeDiscovery Tests**
Tests for discovery features:
- StudyBuddyRecommendation model
- DiscoveryViewModel and StudyBuddyRecommendationService

**Test File:** `ShareACoffeeDiscovery/Tests/ShareACoffeeDiscoveryTests/ShareACoffeeDiscoveryTests.swift`

### 5. **ShareACoffeeStudy Tests**
Tests for study session features:
- StudySession model initialization
- StudySessionService, LiveSessionService, SessionRecapService

**Test File:** `ShareACoffeeStudy/Tests/ShareACoffeeStudyTests/ShareACoffeeStudyTests.swift`

### 6. **ShareACoffeeCoffee Tests**
Tests for coffee shop and location features:
- CoffeeShop model with Location
- CoffeeExperienceService, LocationService, QRCodeService

**Test File:** `ShareACoffeeCoffee/Tests/ShareACoffeeCoffeeTests/ShareACoffeeCoffeeTests.swift`

### 7. **ShareACoffeeBlog Tests**
Tests for blog features:
- BlogPost model initialization
- BlogService singleton access

**Test File:** `ShareACoffeeBlog/Tests/ShareACoffeeBlogTests/ShareACoffeeBlogTests.swift`

### 8. **ShareACoffeeProfile Tests**
Basic compilation tests for the Profile package

**Test File:** `ShareACoffeeProfile/Tests/ShareACoffeeProfileTests/ShareACoffeeProfileTests.swift`

---

## Running Tests in Xcode

### Method 1: Run All Tests
1. Press `⌘U` (Command + U)
   - This runs all unit tests across all packages
   
### Method 2: Run Tests for Specific Package
1. In the Test Navigator (Cmd+5), select the package test class
2. Click the play button, or press `⌘U`

### Method 3: Run From Command Line
```bash
cd /Users/benh/Documents/Cafe_Meetup/ShareACoffee
xcodebuild test -scheme StudyBrew
```

---

## Expected Test Results

✅ **All tests should pass** if:
- All imports are correct
- All types are properly defined in their packages
- All service singletons are accessible
- Package dependency graph is correct

⚠️ **If tests fail:**
1. Check the error message carefully
2. If it's "Cannot find type 'X' in scope" → Add missing import to the test file or the package
3. If it's "Cannot find module 'Y'" → Verify the package dependency in Package.swift

---

## What These Tests Verify

| Test Category | Verifies |
|---|---|
| Model Initialization | Types exist and can be instantiated |
| Service Singletons | All services are properly accessible |
| Import Statements | All cross-package imports work correctly |
| Type Scope | All types used are available in their scope |
| Syntax Correctness | No compilation errors in any package |

---

## Example: Adding a New Test

To verify a new feature, add a test method to the appropriate package test file:

```swift
func testNewFeature() {
    let feature = NewFeature(id: "test", name: "Test")
    XCTAssertEqual(feature.id, "test")
}
```

Then run `⌘U` to verify compilation.

---

## Troubleshooting

### Issue: "Cannot find type 'X' in scope"
**Solution:** Add the missing import at the top of your test file:
```swift
import ShareACoffeeCore
import ShareACoffeeSocial
// etc.
```

### Issue: Test target build fails
**Solution:** 
1. Make sure the package has a `Package.swift` file
2. Verify the test target is configured in `Package.swift`
3. Check that dependencies are correctly listed

### Issue: Xcode can't find package dependencies
**Solution:**
1. Close Xcode
2. Delete `DerivedData`: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Reopen Xcode and wait for indexing to complete

---

## Continuous Integration

To run tests in CI/CD pipeline:
```bash
xcodebuild test \
  -scheme StudyBrew \
  -destination 'generic/platform=iOS' \
  -resultBundlePath test_results.xcresult
```

---

## Next Steps

After verifying all tests pass:
1. ✅ Verify project builds cleanly
2. ✅ Update ShareACoffeeApp.swift with all package imports
3. ✅ Update MainTabView.swift to use package views
4. ✅ Run full app on simulator
5. ✅ Deploy to TestFlight
