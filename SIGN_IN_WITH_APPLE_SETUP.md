# Sign in with Apple Setup Guide

## Current Error
**Error 1000**: Sign in with Apple is not properly configured in Apple Developer Portal.

## Required Steps to Fix

### 1. Go to Apple Developer Portal
Visit: https://developer.apple.com/account/resources/identifiers/list

### 2. Find or Create App ID
- Look for App ID: **com.holsinger.cafe**
- If it doesn't exist, create it:
  - Click the **+** button
  - Select **App IDs**
  - Select **App** type
  - Enter Description: "CafeMeetup"
  - Bundle ID: **com.holsinger.cafe** (Explicit)

### 3. Enable Sign in with Apple Capability
- Select your App ID (com.holsinger.cafe)
- Click **Edit**
- Scroll to **Sign in with Apple**
- Check the box to enable it
- Choose "Enable as a primary App ID"
- Click **Save**

### 4. Update Provisioning Profile (if using one)
- Go to Profiles section
- Find your development/distribution profile
- Click **Edit**
- Regenerate the profile
- Download and install it

### 5. Verify in Xcode
- Open CafeMeetup.xcodeproj
- Select the CafeMeetup target
- Go to **Signing & Capabilities** tab
- Verify **Sign in with Apple** capability is listed
- Verify Team: **PL58734CZ4** is selected
- Verify Bundle Identifier: **com.holsinger.cafe**

### 6. Clean and Rebuild
```bash
cd /Users/benh/Documents/Cafe_Meetup/CafeMeetup
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean -scheme CafeMeetup
xcodebuild -scheme CafeMeetup -destination 'generic/platform=iOS'
```

### 7. Test on Device
- Connect your iPhone 16 Pro
- Build and run from Xcode
- Tap "Sign in with Apple"
- Should now work without error 1000!

## Alternative: Test with Email/Password
While setting up Sign in with Apple, you can use the email/password sign up/sign in options which work immediately without any Apple Developer Portal configuration.

## Verification
Once configured, the console logs should show:
```
🍎 [SignUp] SignInWithAppleButton onRequest called
✅ [SignUp] Apple Sign In successful
🍎 [SignUp] User ID: [your-apple-id]
✅ [AuthViewModel] Sign in successful
```

## Troubleshooting
- Make sure you're signed into iCloud on your iPhone
- Ensure your Apple ID has two-factor authentication enabled
- Try logging out and back into iCloud on the device
- Check that your app's bundle ID matches exactly: com.holsinger.cafe
