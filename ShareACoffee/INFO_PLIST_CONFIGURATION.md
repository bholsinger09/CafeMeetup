# Info.plist Configuration for Live Session and AR Features

## Required Permissions and Entries

### 1. Camera Access (for AR Features)
The AR Cafe Finder requires camera access to display augmented reality content.

**Key:** `NSCameraUsageDescription`  
**Type:** String  
**Value:** "Camera access is required to use AR navigation to find nearby coffee shops and study locations."

### 2. Location When In Use
Required for AR navigation and displaying nearby cafes.

**Key:** `NSLocationWhenInUseUsageDescription`  
**Type:** String  
**Value:** "Your location is used to show nearby coffee shops and other students in your area."

### 3. Location Always (Optional, for background location)
If you want to update user location in the background:

**Key:** `NSLocationAlwaysAndWhenInUseUsageDescription`  
**Type:** String  
**Value:** "Location access allows us to notify you of study sessions near your current location."

### 4. ARKit Usage (Required for AR)
Declares that the app uses ARKit features.

**Key:** `NSARKitUsageDescription`  
**Type:** String  
**Value:** "AR is used to provide an immersive navigation experience to nearby coffee shops."

### 5. Required Device Capabilities
Add to ensure app is only available on devices that support ARKit:

**Key:** `UIRequiredDeviceCapabilities`  
**Type:** Array  
**Items:**
- `arkit` (String)

### 6. Background Modes (Optional, for Firebase Real-time Database)
If you want to receive updates while app is in background:

**Key:** `UIBackgroundModes`  
**Type:** Array  
**Items:**
- `remote-notification` (String)
- `fetch` (String)

## How to Add to Info.plist

### Option 1: Xcode Property List Editor
1. Open your project in Xcode
2. Select the **ShareACoffee** target
3. Go to the **Info** tab
4. Click the **+** button to add new entries
5. Add each key above with its corresponding type and value

### Option 2: Source Code Editor
1. Right-click on `Info.plist` in Xcode
2. Select "Open As" → "Source Code"
3. Add entries within the `<dict>` tags:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to use AR navigation to find nearby coffee shops and study locations.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is used to show nearby coffee shops and other students in your area.</string>

<key>NSARKitUsageDescription</key>
<string>AR is used to provide an immersive navigation experience to nearby coffee shops.</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
</array>
```

## Feature Requirements Summary

### Real-time Collaboration Features
- ✅ **Collaborative Whiteboard** - No special permissions needed
- ✅ **Synchronized Pomodoro Timer** - No special permissions needed
- ✅ **Live Polls** - No special permissions needed
- ✅ **Live Quizzes** - No special permissions needed

**Dependencies:** Firebase Realtime Database (already configured)

### AR Cafe Finder
- ⚠️ **Camera Permission** - Required (`NSCameraUsageDescription`)
- ⚠️ **Location Permission** - Required (`NSLocationWhenInUseUsageDescription`)
- ⚠️ **ARKit Usage** - Required (`NSARKitUsageDescription`)
- ⚠️ **Device Capability** - ARKit-capable device

**Dependencies:** ARKit, CoreLocation, MapKit

## Testing

### Test AR Support
```swift
import ARKit

// Check if device supports AR
if ARWorldTrackingConfiguration.isSupported {
    print("✅ AR is supported on this device")
} else {
    print("❌ AR is NOT supported on this device")
}
```

### Test Location Services
```swift
import CoreLocation

let manager = CLLocationManager()
let status = manager.authorizationStatus

switch status {
case .authorizedWhenInUse, .authorizedAlways:
    print("✅ Location permission granted")
case .denied, .restricted:
    print("❌ Location permission denied")
case .notDetermined:
    print("⚠️ Location permission not yet requested")
@unknown default:
    print("⚠️ Unknown location permission status")
}
```

## Device Compatibility

### Minimum Requirements
- **iOS Version:** 16.0+
- **ARKit Support:** iPhone 6s and later, iPad (5th generation) and later
- **Camera:** Required for AR features
- **GPS:** Required for location-based features

### Recommended Devices
- iPhone 12 and later (best AR performance)
- iPad Pro (2020) and later
- Devices with LiDAR scanner for enhanced AR experience

## Troubleshooting

### "AR features not working"
1. Check device supports ARKit
2. Verify camera permission is granted
3. Ensure `NSCameraUsageDescription` is in Info.plist
4. Restart the app after granting permissions

### "Location not updating"
1. Check location permission status
2. Verify `NSLocationWhenInUseUsageDescription` is in Info.plist
3. Make sure Location Services are enabled in Settings
4. Try requesting permission again

### "Real-time features not syncing"
1. Check internet connection
2. Verify Firebase Realtime Database rules allow read/write
3. Check Firebase console for errors
4. Ensure user is authenticated

## Security Considerations

### Location Privacy
- Only request "When In Use" permission initially
- Explain clearly why location is needed
- Allow users to use app without location (with reduced features)

### Camera Privacy
- Only activate camera when AR view is opened
- Show clear indicator when camera is active
- Allow users to exit AR view easily

### Firebase Security
- Implement proper security rules for real-time database
- Validate all user inputs before syncing
- Limit read/write access to authenticated users only
- Use server-side timestamps to prevent time manipulation

## Production Checklist

Before releasing to App Store:

- [ ] All Info.plist entries added
- [ ] Permissions requested at appropriate times (not on launch)
- [ ] Clear permission rationale shown to users
- [ ] Graceful degradation when permissions denied
- [ ] AR feature disabled on unsupported devices
- [ ] Firebase security rules reviewed and tested
- [ ] Error handling for all edge cases
- [ ] Testing on multiple device types
- [ ] App Store description mentions AR and location features
- [ ] Privacy policy updated to include data usage
