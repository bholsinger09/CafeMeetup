import Foundation
import CoreLocation
import MapKit
import Combine

/// ViewModel for discovering nearby coffee shops within a 15-mile radius
@MainActor
class NearbyCoffeeShopsViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var nearbyCoffeeShops: [CoffeeShop] = []
    @Published var isLoading = false
    @Published var isRequestingPermission = false
    @Published var errorMessage: String?
    @Published var cacheTimestamp: Date?
    
    // Filters
    @Published var showOnlyOpenNow = false
    @Published var selectedAmenities: Set<String> = []
    @Published var minimumRating: Double = 0.0
    @Published var sortOption: SortOption = .distance
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private let searchRadius: CLLocationDistance = 24140 // 15 miles in meters
    private let cacheExpirationInterval: TimeInterval = 300 // 5 minutes
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Enums
    
    enum SortOption {
        case distance
        case rating
        case studyScore
        case name
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setupFilterPublishers()
    }
    
    // MARK: - Public Methods
    
    /// Check location permission status and fetch shops if authorized
    func checkLocationPermissionAndFetch() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            isRequestingPermission = true
        case .restricted, .denied:
            errorMessage = "Location access is denied. Please enable it in Settings to find nearby coffee shops."
            isRequestingPermission = false
        case .authorizedWhenInUse, .authorizedAlways:
            isRequestingPermission = false
            Task {
                await fetchNearbyCoffeeShops()
            }
        @unknown default:
            errorMessage = "Unknown location authorization status"
        }
    }
    
    /// Request location permission from user
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Fetch nearby coffee shops using MapKit search
    func fetchNearbyCoffeeShops() async {
        // Check cache first
        if let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheExpirationInterval,
           !nearbyCoffeeShops.isEmpty {
            return // Use cached data
        }
        
        guard let userLocation = locationManager.location?.coordinate else {
            errorMessage = "Unable to get your location. Please try again."
            return
        }
        
        self.userLocation = userLocation
        isLoading = true
        errorMessage = nil
        
        do {
            let shops = try await searchCoffeeShops(near: userLocation)
            let shopsWithDistance = calculateDistances(for: shops, from: userLocation)
            let filteredShops = applyFilters(to: shopsWithDistance)
            let sortedShops = sortShops(filteredShops)
            
            nearbyCoffeeShops = sortedShops
            cacheTimestamp = Date()
            isLoading = false
        } catch {
            errorMessage = "Failed to find coffee shops: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Clear all filters
    func clearFilters() {
        showOnlyOpenNow = false
        selectedAmenities.removeAll()
        minimumRating = 0.0
        sortOption = .distance
    }
    
    // MARK: - Private Methods
    
    /// Search for coffee shops using MKLocalSearch
    private func searchCoffeeShops(near coordinate: CLLocationCoordinate2D) async throws -> [CoffeeShop] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "coffee shop cafe"
        searchRequest.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: searchRadius * 2,
            longitudinalMeters: searchRadius * 2
        )
        searchRequest.resultTypes = [.pointOfInterest]
        
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        
        var shops: [CoffeeShop] = []
        
        for item in response.mapItems {
            guard let name = item.name,
                  let location = item.placemark.location else {
                continue
            }
            
            // Calculate distance to filter out shops beyond 15 miles
            let shopLocation = CLLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            let userCLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distanceInMeters = shopLocation.distance(from: userCLLocation)
            let distanceInMiles = distanceInMeters / 1609.34
            
            // Only include shops within 15 miles
            guard distanceInMiles <= 15 else { continue }
            
            let shop = CoffeeShop(
                id: UUID().uuidString,
                name: name,
                address: formatAddress(from: item.placemark),
                city: item.placemark.locality ?? "",
                state: item.placemark.administrativeArea ?? "",
                zipCode: item.placemark.postalCode ?? "",
                location: Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ),
                phoneNumber: item.phoneNumber,
                website: item.url?.absoluteString,
                rating: extractRating(from: item),
                amenities: inferAmenities(from: name),
                studyEnvironment: generateStudyEnvironment()
            )
            
            shops.append(shop)
        }
        
        return shops
    }
    
    /// Calculate distances for all shops from user location
    private func calculateDistances(for shops: [CoffeeShop], from userCoordinate: CLLocationCoordinate2D) -> [CoffeeShop] {
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        
        return shops.map { shop in
            var shopWithDistance = shop
            let shopLocation = CLLocation(
                latitude: shop.location.latitude,
                longitude: shop.location.longitude
            )
            let distanceInMeters = shopLocation.distance(from: userLocation)
            shopWithDistance.distance = distanceInMeters / 1609.34 // Convert to miles
            return shopWithDistance
        }
    }
    
    /// Apply currently selected filters
    private func applyFilters(to shops: [CoffeeShop]) -> [CoffeeShop] {
        var filtered = shops
        
        // Filter by minimum rating
        if minimumRating > 0 {
            filtered = filtered.filter { ($0.rating ?? 0) >= minimumRating }
        }
        
        // Filter by selected amenities
        if !selectedAmenities.isEmpty {
            filtered = filtered.filter { shop in
                !selectedAmenities.isDisjoint(with: Set(shop.amenities))
            }
        }
        
        // Filter by open now (if hours are available)
        if showOnlyOpenNow {
            filtered = filtered.filter { shop in
                isCurrentlyOpen(shop)
            }
        }
        
        return filtered
    }
    
    /// Sort shops based on selected option
    private func sortShops(_ shops: [CoffeeShop]) -> [CoffeeShop] {
        switch sortOption {
        case .distance:
            return shops.sorted { ($0.distance ?? Double.greatestFiniteMagnitude) < ($1.distance ?? Double.greatestFiniteMagnitude) }
        case .rating:
            return shops.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .studyScore:
            return shops.sorted { $0.studyScore > $1.studyScore }
        case .name:
            return shops.sorted { $0.name < $1.name }
        }
    }
    
    /// Check if a coffee shop is currently open
    private func isCurrentlyOpen(_ shop: CoffeeShop) -> Bool {
        guard let hours = shop.hours else { return true } // Assume open if no hours data
        
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now) // 1 = Sunday, 2 = Monday, etc.
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        // Map weekday to day name
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let dayIndex = (weekday + 6) % 7 // Convert from Calendar weekday (1=Sunday) to 0-indexed
        let dayName = dayNames[dayIndex]
        
        guard let todayHours = hours.first(where: { $0.day == dayName }) else {
            return true // Assume open if no hours specified for today
        }
        
        // If marked as closed
        if todayHours.isClosed {
            return false
        }
        
        let currentMinutes = (currentTime.hour ?? 0) * 60 + (currentTime.minute ?? 0)
        let openMinutes = parseTimeToMinutes(todayHours.openTime)
        let closeMinutes = parseTimeToMinutes(todayHours.closeTime)
        
        // Handle case where shop closes after midnight
        if closeMinutes < openMinutes {
            return currentMinutes >= openMinutes || currentMinutes < closeMinutes
        }
        
        return currentMinutes >= openMinutes && currentMinutes < closeMinutes
    }
    
    /// Parse time string (e.g., "09:00") to minutes since midnight
    private func parseTimeToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return 0
        }
        return hours * 60 + minutes
    }
    
    /// Format address from placemark
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let street = placemark.thoroughfare {
            if let number = placemark.subThoroughfare {
                addressComponents.append("\(number) \(street)")
            } else {
                addressComponents.append(street)
            }
        }
        
        if addressComponents.isEmpty, let name = placemark.name {
            return name
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    /// Extract rating from map item (if available from Apple Maps data)
    private func extractRating(from mapItem: MKMapItem) -> Double? {
        // Note: MKMapItem doesn't expose ratings directly in iOS 16+
        // This would need to be enhanced with a third-party API like Yelp or Google Places
        return nil
    }
    
    /// Infer likely amenities based on coffee shop name
    private func inferAmenities(from name: String) -> [String] {
        var amenities: [String] = []
        let lowercasedName = name.lowercased()
        
        // Common indicators for amenities
        if lowercasedName.contains("starbucks") || lowercasedName.contains("peet") {
            amenities = ["WiFi", "Outlets", "Long Hours"]
        }
        
        if lowercasedName.contains("library") || lowercasedName.contains("study") {
            amenities.append("Quiet Space")
        }
        
        // Default amenities for coffee shops
        if amenities.isEmpty {
            amenities = ["WiFi", "Seating"]
        }
        
        return amenities
    }
    
    /// Generate study environment data (placeholder - could integrate real reviews)
    private func generateStudyEnvironment() -> StudyEnvironment {
        // This is a placeholder. In production, this would come from:
        // - User reviews and ratings
        // - Crowdsourced data
        // - Third-party APIs
        return StudyEnvironment(
            wifiSpeed: .good,
            noiseLevel: .moderate,
            outletsAvailability: .some,
            seatingComfort: .good,
            groupStudyCapacity: 4,
            hasPrivateRooms: false,
            bestStudyHours: nil,
            studentReviews: 0
        )
    }
    
    /// Setup publishers to react to filter changes
    private func setupFilterPublishers() {
        Publishers.CombineLatest4(
            $showOnlyOpenNow,
            $selectedAmenities,
            $minimumRating,
            $sortOption
        )
        .dropFirst() // Ignore initial values
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.applyFiltersAndSort()
        }
        .store(in: &cancellables)
    }
    
    /// Apply filters and re-sort current list
    private func applyFiltersAndSort() {
        guard userLocation != nil else { return }
        
        let filtered = applyFilters(to: nearbyCoffeeShops)
        nearbyCoffeeShops = sortShops(filtered)
    }
}

// MARK: - CLLocationManagerDelegate

extension NearbyCoffeeShopsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissionAndFetch()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location updated, could refresh shops if needed
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }
}
