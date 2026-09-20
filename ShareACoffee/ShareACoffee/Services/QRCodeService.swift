import Foundation
import Vision
import CoreImage

/// Service for generating and reading QR codes
public final class QRCodeService: Sendable {
    public nonisolated(unsafe) static let shared = QRCodeService()
    
    private init() {}
    
    // MARK: - QR Code Types
    
    /// Types of QR codes supported
    public enum QRCodeType {
        case sessionJoin(String)
        case userProfile(String)
        case coffeeShop(String)
        case other(String)
    }
    
    /// Data decoded from QR code
    public struct QRCodeData: Identifiable {
        public let id: String
        public let rawData: String
        public let type: QRCodeType
        public let timestamp: Date
        public let name: String?
        public let codeType: String?
        
        public init(
            id: String = UUID().uuidString,
            rawData: String,
            type: QRCodeType,
            timestamp: Date = Date(),
            name: String? = nil,
            codeType: String? = nil
        ) {
            self.id = id
            self.rawData = rawData
            self.type = type
            self.timestamp = timestamp
            self.name = name
            self.codeType = codeType
        }
    }
    
    // MARK: - QR Code Generation
    
    /// Generate a QR code image from text
    public func generateQRCode(from string: String) -> CIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        return filter?.outputImage
    }
    
    /// Generate QR code for study session
    public func generateStudySessionQRCode(sessionId: String) -> CIImage? {
        let qrString = "session:\(sessionId)"
        return generateQRCode(from: qrString)
    }
    
    // MARK: - QR Code Recognition
    
    /// Decode QR code from image
    public func recognizeQRCode(image: CIImage) -> String? {
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first as? VNBarcodeObservation,
                  let payload = result.payloadStringValue else {
                return nil
            }
            return payload
        } catch {
            return nil
        }
    }
    
    /// Parse QR code string into structured data
    public func parseQRCode(_ data: String) -> QRCodeData? {
        if data.hasPrefix("session:") {
            let sessionId = String(data.dropFirst(8))
            return QRCodeData(rawData: data, type: .sessionJoin(sessionId), name: "Study Session", codeType: "session")
        } else if data.hasPrefix("user:") {
            let userId = String(data.dropFirst(5))
            return QRCodeData(rawData: data, type: .userProfile(userId), name: "User Profile", codeType: "user")
        } else if data.hasPrefix("cafe:") {
            let cafeId = String(data.dropFirst(5))
            return QRCodeData(rawData: data, type: .coffeeShop(cafeId), name: "Coffee Shop", codeType: "cafe")
        } else {
            return QRCodeData(rawData: data, type: .other(data), name: "Other", codeType: "other")
        }
    }
    
    /// Validate QR code format
    public func isQRCodeValid(_ data: String) -> Bool {
        return !data.isEmpty && data.count <= 2953 // QR code max capacity
    }
}
