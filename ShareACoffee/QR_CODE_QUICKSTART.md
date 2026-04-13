# QR Code Feature - Quick Reference

## 🎯 Where Users Can Get QR Codes

### 1. **As a Session Host**
- Navigate to any **Live Study Session** you're hosting
- Tap the **QR code icon** (📱) in the top-left corner
- QR code screen opens with sharing options

### 2. **What Hosts Can Do with QR Codes**
- ✅ **Share** via Messages, Email, AirDrop, Social Media
- ✅ **Save to Photos** for printing or later use
- ✅ **Copy Link** to clipboard for text sharing
- ✅ Valid for **24 hours** from creation

---

## 📷 Where Users Can Scan QR Codes

### 1. **Floating Scan Button**
- **Location**: Bottom-right corner of EVERY tab
- **Blue/Purple gradient circle** with viewfinder icon
- **Always accessible** from anywhere in the app

### 2. **How to Scan**
1. Tap the floating QR button
2. Grant camera permission (first time only)
3. Point camera at QR code
4. Auto-detects and shows preview
5. Tap "Join Study Session" to join instantly

### 3. **Manual Entry Backup**
- Can't scan? Tap **"Enter Code Manually"**
- Type/paste session code from host
- Works without camera

---

## 🔧 One-Time Setup Required

### **IMPORTANT**: Add Camera Permission

Before the QR scanner will work, you must add camera permission:

1. **Open Xcode** → Select project → Select **ShareACoffee** target
2. Go to **Info** tab
3. Add this key-value pair:

```
Privacy - Camera Usage Description
```
```
We need camera access to scan QR codes for joining study sessions and checking into cafes.
```

**Or** add to Info.plist directly:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes for joining study sessions and checking into cafes.</string>
```

---

## 📁 Files Created

```
Services/
  └── QRCodeService.swift                 # Core QR generation/parsing

Views/QRCode/
  ├── QRCodeGeneratorView.swift           # Create & share QR codes  
  └── QRCodeScannerView.swift             # Scan QR codes with camera

Modified:
  - MainTabView.swift                     # Added floating scan button
  - LiveStudySessionView.swift            # Added QR icon for hosts
```

---

## ✨ Features at a Glance

### **QR Code Generation**
- 🎓 Study session codes (expire in 24 hours)
- ☕ Cafe check-in codes (permanent)
- 🌍 AR location markers (permanent)
- 📤 Multiple share options
- 💾 Save to photos
- 🔗 Copy deep links

### **QR Code Scanner**
- 📸 Auto-detection camera scanning
- ✅ Format validation
- ⏰ Expiration checking
- ⌨️ Manual entry fallback
- 📳 Haptic feedback on success
- 🎨 Beautiful preview UI

### **User Experience**
- **Hosts**: One tap to generate and share
- **Students**: One tap to scan and join
- **Always accessible**: Floating button on all screens
- **No typing**: Scan instead of entering codes
- **Offline-ready**: QR codes work without internet

---

## 🎨 UI Highlights

### **Generator Screen**
- Large, scannable QR code display
- Session info card (course, cafe, time)
- Three action buttons (Share, Save, Copy)
- Step-by-step instructions
- 24-hour validity countdown

### **Scanner Screen**
- Full-screen camera view
- Animated scan frame
- Blue corner brackets for guidance
- Animated scan line
- Manual entry option
- Success animation

### **Floating Button**
- Blue/purple gradient
- QR viewfinder icon
- Bottom-right placement
- Doesn't block tab navigation
- Subtle shadow effect

---

## 🚀 Use Cases

1. **Quick Session Discovery**
   - Host posts QR code on social media
   - Friends scan to join instantly
   - No need to search or type codes

2. **Campus Flyers**
   - Print QR code on study session posters
   - Post around campus
   - Students scan to join

3. **Classroom Announcements**
   - Professor shares group study QR
   - Display on screen during class
   - Students scan to join

4. **Study Group Coordination**
   - Text QR code image to study buddies
   - Everyone scans to join same session
   - Faster than manual invites

5. **Cafe Check-Ins**
   - Cafes display QR codes at tables
   - Students scan to check in
   - Unlock cafe-specific features

---

## 🔒 Security & Privacy

- ✅ QR codes contain only necessary public info
- ✅ Session codes expire after 24 hours
- ✅ No personal data in QR codes
- ✅ Camera access only when scanning
- ✅ Validation prevents malicious codes
- ✅ Deep links use app-specific scheme

---

## 🐛 Common Issues

**Camera won't open?**
→ Add camera permission to Info.plist (see setup above)

**QR code won't scan?**
→ Use "Enter Code Manually" button

**"Code expired" error?**
→ Ask host to generate new QR code

**Can't share QR code?**
→ Try "Save to Photos" then share from Photos app

---

## 📖 Full Documentation

- **Setup Guide**: `QR_CODE_SETUP.md` - Complete setup instructions
- **Code Examples**: `QR_CODE_EXAMPLES.md` - Integration examples for developers
- **This File**: Quick reference for users and developers

---

**Ready to use!** Just add the camera permission and you're all set! 🎉
