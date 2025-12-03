# App Icon Setup Instructions

## Your image has been uploaded and is ready to use!

### Quick Setup:

1. **Save the uploaded image:**
   - The image you uploaded needs to be saved to: `AppIconSource/app_icon_source.jpg`
   - I'll do this for you automatically

2. **Install Pillow (if not already installed):**
   ```bash
   pip3 install Pillow
   ```

3. **Run the icon generator:**
   ```bash
   cd /Users/benh/Documents/Cafe_Meetup/CafeMeetup
   python3 generate_app_icons.py
   ```

4. **Open in Xcode:**
   - Open your project in Xcode
   - Navigate to Assets.xcassets/AppIcon.appiconset
   - You should see all icon sizes populated

5. **Build and run!**

## What Gets Generated:

The script creates these icon sizes:
- 1024x1024 (App Store)
- 180x180 (iPhone 3x)
- 167x167 (iPad Pro)
- 152x152 (iPad 2x)
- 120x120 (iPhone 2x)
- 87x87 (Settings 3x)
- 80x80 (Settings 2x)
- 76x76 (iPad)
- 60x60 (iPhone)
- 58x58 (Settings 2x)
- 40x40 (Spotlight)
- 29x29 (Settings)
- 20x20 (Notification)

Plus the Contents.json file for Xcode.

## Troubleshooting:

- If you get "PIL not found", run: `pip3 install Pillow`
- If you get "command not found: python3", try: `python generate_app_icons.py`
- Make sure the source image is saved in AppIconSource/app_icon_source.jpg

## Manual Alternative:

If you prefer to do this manually:
1. Use an online tool like https://appicon.co or https://makeappicon.com
2. Upload your image
3. Download the generated icon set
4. Replace the contents of CafeMeetup/Assets.xcassets/AppIcon.appiconset with the downloaded files
