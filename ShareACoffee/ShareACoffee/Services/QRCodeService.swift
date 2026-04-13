import Foundation
import CoreImage
import UIKit

/// QR Code Service - Generate and parse QR codes for study sessions and cafes
class QRCodeService {
    static let shared = QRCodeService()
    
    private init() {}
    
    // MARK: - QR Code Types
    
    enum QRCodeType: String {
        case studySession = "session"
        case cafeCheckIn = "cafe"
        case arMarker = "ar"
    }
    
    struct QRCodeData: Codable {
        let type: String
        let id: String
        let name: String
        let details: [String: String]?
        let timestamp: Date
        
        var codeType: QRCodeType? {
            QRCodeType(rawValue: type)
        }
    }
    
    // MARK: - Generate QR Codes
    
    /// Generate QR code for a study session
    func generateStudySessionQRCode(
        sessionId: String,
        sessionName: String,
        cafeName: String,
        hostName: String
    ) -> UIImage? {
        let data = QRCodeData(
            type: QRCodeType.studySession.rawValue,
            id: sessionId,
            name: sessionName,
            details: [
                "cafe": cafeName,
                "host": hostName
            ],
            timestamp: Date()
        )
        
        return generateQRCode(from: data)
    }
    
    /// Generate QR code for cafe check-in
    func generateCafeQRCode(
        cafeId: String,
        cafeName: String,
        address: String?
    ) -> UIImage? {
        var details: [String: String] = [:]
        if let address = address {
            details["address"] = address
        }
        
        let data = QRCodeData(
            type: QRCodeType.cafeCheckIn.rawValue,
            id: cafeId,
            name: cafeName,
            details: details.isEmpty ? nil : details,
            timestamp: Date()
        )
        
        return generateQRCode(from: data)
    }
    
    /// Generate QR code for AR marker
    func generateARMarkerQRCode(
        cafeId: String,
        cafeName: String,
        latitude: Double,
        longitude: Double
    ) -> UIImage? {
        let data = QRCodeData(
            type: QRCodeType.arMarker.rawValue,
            id: cafeId,
            name: cafeName,
            details: [
                "lat": String(latitude),
                "lon": String(longitude)
            ],
            timestamp: Date()
        )
        
        return generateQRCode(from: data)
    }
    
    // MARK: - Core QR Generation
    
    private func generateQRCode(from data: QRCodeData) -> UIImage? {
        guard let jsonData = try? JSONEncoder().encode(data),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        return generateQRCodeImage(from: jsonString)
    }
    
    private func generateQRCodeImage(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
        
        guard let ciImage = filter.outputImage else {
            return nil
        }
        
        // Scale up the QR code for better quality
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Parse QR Codes
    
    /// Parse QR code data from scanned string
    func parseQRCode(from string: String) -> QRCodeData? {
        guard let data = string.data(using: .utf8),
              let qrData = try? JSONDecoder().decode(QRCodeData.self, from: data) else {
            return nil
        }
        
        return qrData
    }
    
    /// Validate QR code is not expired (24 hours for sessions, permanent for cafes)
    func isQRCodeValid(_ qrData: QRCodeData) -> Bool {
        guard let codeType = qrData.codeType else {
            return false
        }
        
        switch codeType {
        case .studySession:
            // Study session QR codes expire after 24 hours
            let expirationDate = qrData.timestamp.addingTimeInterval(24 * 3600)
            return Date() < expirationDate
            
        case .cafeCheckIn, .arMarker:
            // Cafe and AR QR codes don't expire
            return true
        }
    }
}
