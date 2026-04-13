# QR Code Integration Examples

This file shows how to use the QR code services in different parts of the app.

## Generating QR Codes

### Example 1: Generate QR Code for Study Session

```swift
import SwiftUI

struct SessionDetailView: View {
    let session: StudySession
    @State private var qrCodeImage: UIImage?
    
    var body: some View {
        VStack {
            if let qrCodeImage = qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onAppear {
            generateQRCode()
        }
    }
    
    private func generateQRCode() {
        qrCodeImage = QRCodeService.shared.generateStudySessionQRCode(
            sessionId: session.id,
            sessionName: "\(session.courseCode): \(session.studyTopic)",
            cafeName: session.cafeName,
            hostName: session.hostName
        )
    }
}
```

### Example 2: Generate QR Code for Cafe

```swift
func createCafeQRCode(for cafe: CoffeeShop) -> UIImage? {
    return QRCodeService.shared.generateCafeQRCode(
        cafeId: cafe.id,
        cafeName: cafe.name,
        address: cafe.address
    )
}
```

### Example 3: Generate AR Marker QR Code

```swift
func createARMarker(for cafe: CoffeeShop) -> UIImage? {
    guard let location = cafe.location else { return nil }
    
    return QRCodeService.shared.generateARMarkerQRCode(
        cafeId: cafe.id,
        cafeName: cafe.name,
        latitude: location.latitude,
        longitude: location.longitude
    )
}
```

## Scanning QR Codes

### Example 1: Show Scanner from Any View

```swift
struct MyView: View {
    @State private var showScanner = false
    
    var body: some View {
        Button("Scan QR Code") {
            showScanner = true
        }
        .fullScreenCover(isPresented: $showScanner) {
            QRCodeScannerView()
        }
    }
}
```

### Example 2: Process Scanned QR Data

```swift
func processScannedCode(_ code: String) {
    // Parse the QR code
    guard let qrData = QRCodeService.shared.parseQRCode(from: code) else {
        print("Invalid QR code format")
        return
    }
    
    // Validate it's not expired
    guard QRCodeService.shared.isQRCodeValid(qrData) else {
        print("QR code has expired")
        return
    }
    
    // Handle based on type
    switch qrData.codeType {
    case .studySession:
        joinStudySession(id: qrData.id, name: qrData.name)
        
    case .cafeCheckIn:
        checkIntoCafe(id: qrData.id, name: qrData.name)
        
    case .arMarker:
        launchARExperience(qrData: qrData)
        
    case .none:
        print("Unknown QR code type")
    }
}

private func joinStudySession(id: String, name: String) {
    // Fetch session from Firebase
    // Add user to attendees
    // Navigate to session view
    print("Joining session: \(name)")
}

private func checkIntoCafe(id: String, name: String) {
    // Record cafe check-in
    // Update user location
    // Show confirmation
    print("Checked into: \(name)")
}

private func launchARExperience(qrData: QRCodeService.QRCodeData) {
    guard let details = qrData.details,
          let latStr = details["lat"],
          let lonStr = details["lon"],
          let lat = Double(latStr),
          let lon = Double(lonStr) else {
        return
    }
    
    // Launch AR view with coordinates
    print("Launching AR at: \(lat), \(lon)")
}
```

## Creating Printable QR Posters

### Example: Generate Poster for Study Session

```swift
struct SessionPosterView: View {
    let session: StudySession
    @State private var qrCodeImage: UIImage?
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            Text("Join Our Study Session!")
                .font(.system(size: 48, weight: .bold))
            
            // Course Info
            VStack(spacing: 10) {
                Text(session.courseCode)
                    .font(.system(size: 36, weight: .semibold))
                Text(session.studyTopic)
                    .font(.system(size: 28))
            }
            
            // QR Code
            if let qrCodeImage = qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .padding(40)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            // Instructions
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    Image(systemName: "1.circle.fill")
                        .font(.system(size: 32))
                    Text("Open StudyBrew App")
                        .font(.system(size: 24))
                }
                
                HStack(spacing: 20) {
                    Image(systemName: "2.circle.fill")
                        .font(.system(size: 32))
                    Text("Tap QR Scanner Button")
                        .font(.system(size: 24))
                }
                
                HStack(spacing: 20) {
                    Image(systemName: "3.circle.fill")
                        .font(.system(size: 32))
                    Text("Scan This Code to Join")
                        .font(.system(size: 24))
                }
            }
            
            // Details
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                    Text(session.cafeName)
                }
                .font(.system(size: 20))
                
                HStack {
                    Image(systemName: "calendar")
                    Text(session.scheduledDate.formatted(date: .long, time: .shortened))
                }
                .font(.system(size: 20))
                
                HStack {
                    Image(systemName: "person.fill")
                    Text("Host: \(session.hostName)")
                }
                .font(.system(size: 20))
            }
        }
        .padding(60)
        .frame(width: 816, height: 1056) // Standard letter size at 72 DPI
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            generateQRCode()
        }
    }
    
    private func generateQRCode() {
        qrCodeImage = QRCodeService.shared.generateStudySessionQRCode(
            sessionId: session.id,
            sessionName: "\(session.courseCode): \(session.studyTopic)",
            cafeName: session.cafeName,
            hostName: session.hostName
        )
    }
}
```

## Adding QR Code to Cafe Profiles

### Example: Show QR Code in Cafe Detail View

```swift
struct CafeDetailView: View {
    let cafe: CoffeeShop
    @State private var showQRCode = false
    @State private var qrCodeImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack {
                // ... other cafe details ...
                
                Button("Show Check-In QR Code") {
                    generateQRCode()
                    showQRCode = true
                }
            }
        }
        .sheet(isPresented: $showQRCode) {
            VStack(spacing: 20) {
                Text("Check In to \(cafe.name)")
                    .font(.title)
                
                if let qrCodeImage = qrCodeImage {
                    Image(uiImage: qrCodeImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                }
                
                Text("Scan this code to check in")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
    
    private func generateQRCode() {
        qrCodeImage = QRCodeService.shared.generateCafeQRCode(
            cafeId: cafe.id,
            cafeName: cafe.name,
            address: cafe.address
        )
    }
}
```

## Deep Linking Integration

### Example: Handle QR Code Deep Links

```swift
// In ShareACoffeeApp.swift

@main
struct ShareACoffeeApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Expected format: studybrew://session/{sessionId}
        
        guard url.scheme == "studybrew" else { return }
        
        if url.host == "session",
           let sessionId = url.pathComponents.last {
            // Navigate to session
            joinSession(id: sessionId)
        } else if url.host == "cafe",
                  let cafeId = url.pathComponents.last {
            // Navigate to cafe
            showCafe(id: cafeId)
        }
    }
    
    private func joinSession(id: String) {
        // TODO: Implement session navigation
        print("Deep link to session: \(id)")
    }
    
    private func showCafe(id: String) {
        // TODO: Implement cafe navigation
        print("Deep link to cafe: \(id)")
    }
}
```

## Testing QR Codes

### Example: Generate Test QR Codes

```swift
struct QRCodeTestView: View {
    @State private var testCodes: [String: UIImage?] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                ForEach(["Session", "Cafe", "AR"], id: \.self) { type in
                    VStack {
                        Text("\(type) QR Code")
                            .font(.headline)
                        
                        if let image = testCodes[type] as? UIImage {
                            Image(uiImage: image)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            generateTestCodes()
        }
    }
    
    private func generateTestCodes() {
        // Test session QR
        testCodes["Session"] = QRCodeService.shared.generateStudySessionQRCode(
            sessionId: "test-session-123",
            sessionName: "CS 101: Test Session",
            cafeName: "Test Cafe",
            hostName: "Test User"
        )
        
        // Test cafe QR
        testCodes["Cafe"] = QRCodeService.shared.generateCafeQRCode(
            cafeId: "test-cafe-456",
            cafeName: "Test Cafe",
            address: "123 Test St"
        )
        
        // Test AR QR
        testCodes["AR"] = QRCodeService.shared.generateARMarkerQRCode(
            cafeId: "test-ar-789",
            cafeName: "AR Test Cafe",
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
}
```
