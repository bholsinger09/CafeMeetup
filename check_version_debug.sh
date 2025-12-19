#!/bin/bash

echo "=== VERSION DEBUGGING SCRIPT ==="
echo ""
echo "Date: $(date)"
echo ""

cd /Users/benh/Documents/Cafe_Meetup/CafeMeetup

echo "1. PROJECT BUILD SETTINGS:"
echo "---"
xcodebuild -project StudyBrew.xcodeproj -target StudyBrew -configuration Release -showBuildSettings | grep -E "MARKETING_VERSION|CURRENT_PROJECT_VERSION"
echo ""

echo "2. INFO.PLIST VALUES:"
echo "---"
/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" CafeMeetup/Info.plist
/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" CafeMeetup/Info.plist
echo ""

echo "3. CHECKING FOR XCARCHIVES:"
echo "---"
ARCHIVE_PATH=~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)
if [ -d "$ARCHIVE_PATH" ]; then
    echo "Archives from today:"
    ls -lt "$ARCHIVE_PATH" | head -5
else
    echo "No archives from today, checking recent archives:"
    find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -mtime -7 -exec ls -ld {} \; | head -5
fi
echo ""

echo "4. CHECKING LATEST ARCHIVE INFO.PLIST:"
echo "---"
LATEST_ARCHIVE=$(find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -mtime -7 | head -1)
if [ -n "$LATEST_ARCHIVE" ]; then
    echo "Latest archive: $LATEST_ARCHIVE"
    APP_PATH=$(find "$LATEST_ARCHIVE" -name "StudyBrew.app" -o -name "CafeMeetup.app" | head -1)
    if [ -n "$APP_PATH" ]; then
        echo "App found at: $APP_PATH"
        echo "Version in archive:"
        /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Info.plist"
        echo "Build in archive:"
        /usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$APP_PATH/Info.plist"
    else
        echo "No app found in archive"
    fi
else
    echo "No recent archives found"
fi
echo ""

echo "5. BUILD AND CHECK:"
echo "---"
echo "Building fresh archive..."
xcodebuild -project StudyBrew.xcodeproj -scheme CafeMeetup -configuration Release clean build -destination "generic/platform=iOS" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO 2>&1 | grep -E "error|warning|Version" || echo "Build command executed"
echo ""

echo "6. CHECKING BUILD PRODUCT:"
echo "---"
BUILD_DIR=$(xcodebuild -project StudyBrew.xcodeproj -scheme CafeMeetup -configuration Release -showBuildSettings | grep " BUILD_DIR = " | sed 's/.*BUILD_DIR = //')
if [ -d "$BUILD_DIR" ]; then
    echo "Build directory: $BUILD_DIR"
    APP_PATH=$(find "$BUILD_DIR" -name "StudyBrew.app" | head -1)
    if [ -n "$APP_PATH" ]; then
        echo "App path: $APP_PATH"
        if [ -f "$APP_PATH/Info.plist" ]; then
            echo "Version in build product:"
            /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Info.plist" 2>/dev/null || echo "Could not read version"
            echo "Build in build product:"
            /usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$APP_PATH/Info.plist" 2>/dev/null || echo "Could not read build"
        fi
    fi
fi
echo ""

echo "=== END DEBUG ==="
