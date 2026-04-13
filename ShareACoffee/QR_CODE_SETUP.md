# QR Code Features - Setup Guide

## Overview

This guide explains how to set up and use the new QR code features in StudyBrew.

## Features Implemented

### 1. **QR Code Generation** 
Users can generate QR codes for:
- **Study Sessions**: Share session links that others can scan to join instantly
- **Cafe Check-Ins**: Create QR codes for cafe locations
- **AR Markers**: Generate location-based AR experiences

### 2. **QR Code Scanning**
Users can scan QR codes to:
- Join study sessions instantly
- Check into cafes
- Access AR experiences

### 3. **Integration Points**

#### Floating Scan Button
- **Location**: Bottom-right corner of all tab screens
- **Action**: Opens full-screen QR code scanner
- **Availability**: Always accessible from main navigation

#### Session Sharing
- **Location**: Live Study Session view (host only)
- **Action**: QR code icon in top-left navigation bar
- **Purpose**: Generate and share session QR codes

---

## Required Setup

### 1. Add Camera Permission to Info.plist

You **must** add camera usage description to your app's `Info.plist` file:

1. In Xcode, select your project in the Navigator
2. Select the **ShareACoffee** target
3. Go to the **Info** tab
4. Click the **+** button to add a new key
5. Add the following:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes for joining study sessions and checking into cafes.</string>
```

Or add this row in the Info tab:
```
Key: Privacy - Camera Usage Description
Type: String
Value: We need camera access to scan QR codes for joining study sessions and checking into cafes.
```

### 2. Add Photo Library Permission (Optional)

If you want users to save QR codes to photos:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save QR codes to your photo library for easy sharing.</string>
```

---

## File Structure

### New Files Created

```
ShareACoffee/
├── Services/
│   └── QRCodeService.swift          # QR code generation and parsing logic
├── Views/
│   └── QRCode/
│       ├── QRCodeGeneratorView.swift   # Generate and display QR codes
│       └── QRCodeScannerView.swift     # Scan QR codes with camera
```

### Modified Files

```
ShareACoffee/
├── Views/
│   ├── MainTabView.swift              # Added floating QR scanner button
│   └── StudySessions/
│       └── LiveStudySessionView.swift # Added QR code generation for hosts
```

---

## How to Use

### For Session Hosts (Creating QR Codes)

1. **Start or join a live study session**
2. **Tap the QR code icon** in the top-left corner (only visible to hosts)
3. **Share options**:
   - **Share QR Code**: Send via Messages, Email, AirDrop, etc.
   - **Save to Photos**: Save for printing or later sharing
   - **Copy Session Link**: Copy deep link to clipboard

4. **QR Code contains**:
   - Session ID
   - Course and topic
   - Cafe name and location
   - Host name
   - Timestamp (valid for 24 hours)

### For Students (Joining via QR Code)

1. **Tap the floating QR button** (bottom-right corner)
2. **Grant camera permission** when prompted
3. **Point camera at QR code** - it will auto-detect and scan
4. **Review session details** in the preview
5. **Tap "Join Study Session"** to join instantly

**Alternative: Manual Entry**
- Can't scan? Tap **"Enter Code Manually"**
- Type or paste the session code
- Tap **"Join Session"**

---

## Technical Details

### QR Code Data Format

QR codes encode JSON data with the following structure:

```json
{
  "type": "session" | "cafe" | "ar",
  "id": "unique-identifier",
  "name": "Display name",
  "details": {
    "key": "value"
  },
  "timestamp": "ISO-8601 date"
}
```

### QR Code Types

1. **Study Session (`session`)**
   - Contains: Session ID, course info, cafe name, host name
   - Expiration: 24 hours from creation
   - Action: Join study session

2. **Cafe Check-In (`cafe`)**
   - Contains: Cafe ID, name, address
   - Expiration: Never (permanent)
   - Action: Check into cafe

3. **AR Marker (`ar`)**
   - Contains: Cafe ID, name, GPS coordinates
   - Expiration: Never (permanent)
   - Action: Launch AR experience

### Scanner Features

- **Auto-detection**: Automatically detects and scans QR codes
- **Validation**: Checks code format and expiration
- **Error handling**: Clear messages for invalid/expired codes
- **Manual entry**: Fallback for camera issues
- **Haptic feedback**: Success vibration on scan

---

## Future Enhancements

Potential improvements for the QR code system:

1. **Batch Joining**: Scan multiple QR codes at once
2. **History**: View previously scanned codes
3. **Custom QR Designs**: Branded QR codes with cafe logos
4. **NFC Support**: Tap-to-join as alternative to scanning
5. **Analytics**: Track how users discover sessions
6. **Physical Posters**: Generate printable session posters with QR codes

---

## Troubleshooting

### Camera Not Working

**Problem**: Scanner shows black screen or permission denied
**Solution**: 
1. Check Info.plist has camera usage description
2. Go to Settings > ShareACoffee > Camera and enable
3. Restart the app

### QR Code Won't Scan

**Problem**: Scanner doesn't detect QR code
**Solution**:
1. Ensure good lighting
2. Hold camera steady
3. Try moving closer/farther away
4. Use manual entry as backup

### QR Code Expired

**Problem**: "This QR code has expired" message
**Solution**:
1. Ask host to generate a new QR code
2. Session QR codes expire after 24 hours
3. Use manual session ID entry instead

### Save to Photos Fails

**Problem**: Can't save QR code image
**Solution**:
1. Check photo library permission in Settings
2. Ensure sufficient storage space
3. Try share instead of save

---

## Testing Checklist

- [ ] Camera permission request appears on first scan
- [ ] QR code generates correctly for sessions
- [ ] Scanner detects QR codes quickly
- [ ] Invalid QR codes show error message
- [ ] Expired QR codes are rejected
- [ ] Manual entry works as fallback
- [ ] Share sheet works on QR generator
- [ ] Save to photos works
- [ ] Session link copies to clipboard
- [ ] Floating button visible on all tabs
- [ ] QR icon visible for session hosts only

---

## Support

For issues or questions:
1. Check this documentation
2. Review error messages in the scanner
3. Try manual entry as backup
4. Ensure app permissions are granted
