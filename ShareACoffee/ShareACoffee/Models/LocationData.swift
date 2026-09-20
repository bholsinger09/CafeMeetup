import Foundation
import CoreLocation

/// Data structure for location information
public struct LocationData: Identifiable, Codable {
    public let id: String
    public let latitude: Double
    public let longitude: Double
    public let name: String?
    public let address: String?
    public let city: String?
    public let state: String?
    public let zipCode: String?
    public let country: String?
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        name: String? = nil,
        address: String? = nil,
        city: String? = nil,
        state: String? = nil,
        zipCode: String? = nil,
        country: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
}
