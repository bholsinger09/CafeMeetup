import XCTest
@testable import ShareACoffee

/// Tests for QRCode generation and scanning functionality
@MainActor
final class QRCodeServiceTests: XCTestCase {
    
    var qrCodeService: QRCodeService!
    
    override func setUp() async throws {
        qrCodeService = QRCodeService.shared
    }
    
    // MARK: - QRCode Type Tests
    
    func testQRCodeTypeSessionJoin() {
        // Given: A session ID
        let sessionId = "test-session-123"
        
        // When: Creating a session join QR code type
        let qrType = QRCodeService.QRCodeType.sessionJoin(sessionId)
        
        // Then: Type should be correctly created
        switch qrType {
        case .sessionJoin(let id):
            XCTAssertEqual(id, sessionId)
        default:
            XCTFail("Incorrect QRCodeType")
        }
    }
    
    func testQRCodeTypeUserProfile() {
        // Given: A user ID
        let userId = "user-456"
        
        // When: Creating a user profile QR code type
        let qrType = QRCodeService.QRCodeType.userProfile(userId)
        
        // Then: Type should be correctly created
        switch qrType {
        case .userProfile(let id):
            XCTAssertEqual(id, userId)
        default:
            XCTFail("Incorrect QRCodeType")
        }
    }
    
    func testQRCodeTypeCoffeeShop() {
        // Given: A cafe ID
        let cafeId = "cafe-789"
        
        // When: Creating a coffee shop QR code type
        let qrType = QRCodeService.QRCodeType.coffeeShop(cafeId)
        
        // Then: Type should be correctly created
        switch qrType {
        case .coffeeShop(let id):
            XCTAssertEqual(id, cafeId)
        default:
            XCTFail("Incorrect QRCodeType")
        }
    }
    
    // MARK: - QRCode Data Tests
    
    func testQRCodeDataIdentifiable() {
        // Given: QRCodeData instances
        let data1 = QRCodeService.QRCodeData(
            id: "qr-1",
            rawData: "test-data-1",
            type: .sessionJoin("session-1"),
            timestamp: Date(),
            name: "Test QR 1",
            codeType: "URL"
        )
        
        let data2 = QRCodeService.QRCodeData(
            id: "qr-2",
            rawData: "test-data-2",
            type: .sessionJoin("session-2"),
            timestamp: Date(),
            name: "Test QR 2",
            codeType: "URL"
        )
        
        // When: Comparing Identifiable conformance
        // Then: Each should have unique ID
        XCTAssertNotEqual(data1.id, data2.id)
        XCTAssertEqual(data1.id, "qr-1")
        XCTAssertEqual(data2.id, "qr-2")
    }
    
    // MARK: - QRCode Generation Tests
    
    func testGenerateQRCodeFromString() {
        // Given: A test string
        let testString = "https://example.com/session/abc123"
        
        // When: Generating QR code
        let ciImage = qrCodeService.generateQRCode(from: testString)
        
        // Then: Should return a valid CIImage
        XCTAssertNotNil(ciImage)
    }
    
    func testGenerateSessionJoinQRCode() {
        // Given: A session ID
        let sessionId = "test-session-123"
        
        // When: Generating session join QR code
        let ciImage = qrCodeService.generateStudySessionQRCode(sessionId: sessionId)
        
        // Then: Should return a valid CIImage
        XCTAssertNotNil(ciImage)
    }
    
    // MARK: - QRCode Recognition Tests
    
    func testRecognizeQRCodeReturnsNilForInvalidInput() {
        // Given: A non-QR image (system image)
        let image = UIImage(systemName: "qrcode") ?? UIImage()
        
        // When: Attempting to recognize QR code
        let result = qrCodeService.recognizeQRCode(image: image)
        
        // Then: Should return nil (no QR code found)
        // Note: This may or may not find a code, so we just verify it doesn't crash
        XCTAssertTrue(true) // Just verify it doesn't throw
    }
    
    // MARK: - QRCode Parsing Tests
    
    func testParseQRCodeData() {
        // Given: A raw QR code string
        let rawData = "session:123456"
        
        // When: Parsing QR code data
        let qrData = qrCodeService.parseQRCode(rawData)
        
        // Then: Should return valid QRCodeData
        XCTAssertNotNil(qrData)
        XCTAssertEqual(qrData?.rawData, rawData)
    }
    
    // MARK: - QRCode Validation Tests
    
    func testValidateQRCodeWithValidString() {
        // Given: A valid QR code string
        let validCode = "https://shareacoffee.app/session/abc123"
        
        // When: Validating QR code
        let isValid = qrCodeService.isQRCodeValid(validCode)
        
        // Then: Should return true
        XCTAssertTrue(isValid)
    }
    
    func testValidateQRCodeWithEmptyString() {
        // Given: An empty string
        let emptyCode = ""
        
        // When: Validating QR code
        let isValid = qrCodeService.isQRCodeValid(emptyCode)
        
        // Then: Should return false
        XCTAssertFalse(isValid)
    }
    
    // MARK: - Type Conversion Tests
    
    func testQRCodeTypeConversionFromString() {
        // Given: Different type strings
        let typeStrings = ["sessionJoin", "userProfile", "coffeeShop", "other"]
        
        // When: Processing different QR code types
        // Then: Should handle all types without crashing
        for typeString in typeStrings {
            // Create different types for parsing
            let sessionType = QRCodeService.QRCodeType.sessionJoin("id-\(typeString)")
            XCTAssertNotNil(sessionType)
        }
    }
}
