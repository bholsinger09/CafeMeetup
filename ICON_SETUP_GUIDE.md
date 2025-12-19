# ShareACoffee App Icon Setup

## Steps to Generate Icons

1. **Save the coffee shop image:**
   - Save the image you provided as `coffee_source.jpg` in `/Users/benh/Documents/Cafe_Meetup/CafeMeetup/`

2. **Install Pillow (if not already installed):**
   ```bash
   pip3 install Pillow
   ```

3. **Run the icon generator:**
   ```bash
   cd /Users/benh/Documents/Cafe_Meetup/CafeMeetup
   python3 generate_icon_from_image.py
   ```

4. **Clean and rebuild in Xcode:**
   - Open the project in Xcode
   - Press Cmd+Shift+K (Clean Build Folder)
   - Press Cmd+B (Build)

## What's Changed

- **App Name:** StudyBrew → ShareACoffee
- **Bundle ID:** com.holsinger.cafe → com.holsinger.shareacoffee  
- **Version:** Reset to 1.0 (Build 1)
- **Display Name:** ShareACoffee
- **Icon:** Will use the coffee shop image you provided

## Important Notes

This is a completely new app identity, so:
- You'll need to create a NEW app in App Store Connect
- New bundle identifier means new provisioning profiles
- This will bypass the "Invalid Binary" issue with the old app
- Fresh start with no previous rejection history

## Next Steps After Icon Generation

1. Update provisioning profiles in Xcode
2. Archive the app (Product → Archive)
3. Create a new app in App Store Connect with bundle ID: `com.holsinger.shareacoffee`
4. Upload the archive
5. Submit for review with the new identity
