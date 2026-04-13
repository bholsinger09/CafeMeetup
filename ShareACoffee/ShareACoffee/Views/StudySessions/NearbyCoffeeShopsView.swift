import SwiftUI
import CoreLocation
import MapKit
import Combine

struct NearbyCoffeeShopsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCafeName: String
    
    @StateObject private var viewModel = NearbyCoffeeShopsViewModel()
    @State private var showManualEntry = false
    @State private var manualCafeName = ""
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isRequestingPermission {
                    locationPermissionView
                } else if viewModel.isLoading {
                    ProgressView("Finding nearby coffee shops...")
                        .scaleEffect(1.2)
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.nearbyCoffeeShops.isEmpty {
                    emptyStateView
                } else {
                    coffeeShopsList
                }
            }
            .navigationTitle("Nearby Coffee Shops")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.checkLocationPermissionAndFetch()
            }
            .alert("Enter Coffee Shop Name", isPresented: $showManualEntry) {
                TextField("Coffee shop name", text: $manualCafeName)
                Button("Cancel", role: .cancel) {
                    manualCafeName = ""
                }
                Button("Add") {
                    if !manualCafeName.isEmpty {
                        selectedCafeName = manualCafeName
                        manualCafeName = ""
                        dismiss()
                    }
                }
            } message: {
                Text("Type the name of your coffee shop exactly as you want it to appear.")
            }
        }
    }
    
    private var locationPermissionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Location Access Needed")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We need your location to show nearby coffee shops within a 15-mile radius.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.requestLocationPermission()
            }) {
                Label("Allow Location Access", systemImage: "location.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var coffeeShopsList: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Showing \(viewModel.nearbyCoffeeShops.count) coffee shops within 15 miles")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let timestamp = viewModel.cacheTimestamp {
                            Text("Updated \(timeAgo(from: timestamp))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.fetchNearbyCoffeeShops()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            ForEach(viewModel.nearbyCoffeeShops) { shop in
                Button(action: {
                    selectedCafeName = shop.name
                    dismiss()
                }) {
                    CoffeeShopRow(shop: shop)
                }
            }
            
            Section {
                Button(action: {
                    showManualEntry = true
                }) {
                    HStack {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                        Text("Can't find your shop? Enter manually")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            let hours = Int(seconds / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.checkLocationPermissionAndFetch()
            }) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Coffee Shops Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No coffee shops found within 15 miles of your location.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showManualEntry = true
            }) {
                Label("Enter Coffee Shop Manually", systemImage: "pencil.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Coffee Shop Row

struct CoffeeShopRow: View {
    let shop: CoffeeShop
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.title2)
                .foregroundColor(.brown)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(shop.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    if let distance = shop.distance {
                        Label(String(format: "%.1f mi", distance), systemImage: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    if let rating = shop.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - View Model

@MainActor
class NearbyCoffeeShopsViewModel: ObservableObject {
    @Published var nearbyCoffeeShops: [CoffeeShop] = []
    @Published var isLoading = false
    @Published var isRequestingPermission = false
    @Published var errorMessage: String?
    @Published var cacheTimestamp: Date?
    
    private let locationService = LocationService.shared
    private let radiusMiles: Double = 15.0
    
    // Cache to prevent hitting MapKit rate limits
    private var cachedShops: [CoffeeShop] = []
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    private var isCacheValid: Bool {
        guard let timestamp = cacheTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < cacheValidityDuration
    }
    
    func checkLocationPermissionAndFetch() {
        let status = CLLocationManager().authorizationStatus
        
        switch status {
        case .notDetermined:
            isRequestingPermission = true
        case .restricted, .denied:
            errorMessage = "Location access is required to find nearby coffee shops. Please enable location access in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            // Use cache if available and valid
            if isCacheValid && !cachedShops.isEmpty {
                nearbyCoffeeShops = cachedShops
            } else {
                Task {
                    await fetchNearbyCoffeeShops()
                }
            }
        @unknown default:
            errorMessage = "Unknown location authorization status"
        }
    }
    
    func requestLocationPermission() {
        locationService.requestAuthorization()
        
        // Wait a moment for permission dialog, then check status
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            isRequestingPermission = false
            checkLocationPermissionAndFetch()
        }
    }
    
    func fetchNearbyCoffeeShops() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userLocation = try await locationService.getCurrentLocation()
            
            // Fetch nearby coffee shops using MapKit local search
            let coffeeShops = try await searchNearbyCoffeeShops(near: userLocation)
            
            // Calculate distances and filter by radius
            let filteredShops = coffeeShops
                .map { shop in
                    var updatedShop = shop
                    let shopLocation = CLLocation(
                        latitude: shop.location.latitude,
                        longitude: shop.location.longitude
                    )
                    let userCLLocation = CLLocation(
                        latitude: userLocation.latitude,
                        longitude: userLocation.longitude
                    )
                    let distanceMeters = userCLLocation.distance(from: shopLocation)
                    let distanceMiles = distanceMeters / 1609.34
                    updatedShop.distance = distanceMiles
                    return updatedShop
                }
                .filter { ($0.distance ?? 0) <= radiusMiles }
                .sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
            
            // Update cache
            self.nearbyCoffeeShops = filteredShops
            self.cachedShops = filteredShops
            self.cacheTimestamp = Date()
            
            isLoading = false
        } catch let error as NSError {
            // Check for MapKit rate limiting error
            if error.domain == "GEOErrorDomain" && error.code == -3 {
                // Use cached results if available
                if !cachedShops.isEmpty {
                    nearbyCoffeeShops = cachedShops
                    errorMessage = "Using cached results. MapKit search limit reached, please wait a moment before refreshing."
                } else {
                    if let resetTime = error.userInfo["timeUntilReset"] as? Int {
                        errorMessage = "Too many searches. Please wait \(resetTime) seconds and try again."
                    } else {
                        errorMessage = "Search limit reached. Please wait a moment and try again."
                    }
                }
            } else {
                errorMessage = "Failed to fetch nearby coffee shops: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func searchNearbyCoffeeShops(near coordinate: CLLocationCoordinate2D) async throws -> [CoffeeShop] {
        // Search with multiple queries to find more results
        let searchQueries = [
            "coffee shop",
            "coffee",
            "cafe",
            "coffeehouse",
            "espresso bar"
        ]
        var allShops: [CoffeeShop] = []
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radiusMiles * 1609.34 * 2,
            longitudinalMeters: radiusMiles * 1609.34 * 2
        )
        
        // Perform searches sequentially to avoid rate limiting
        for query in searchQueries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region
            // Don't restrict resultTypes - let MapKit return all relevant matches
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                print("[NearbyCoffeeShops] Query '\(query)' returned \(response.mapItems.count) results")
                
                let shops = response.mapItems.compactMap { mapItem -> CoffeeShop? in
                    guard let name = mapItem.name else {
                        return nil
                    }
                    
                    // NOTE: placemark deprecated in iOS 26.0, but we target iOS 16.0+
                    // Using placemark is correct for our deployment target
                    // Will migrate when minimum iOS version is 26.0+
                    let placemark = mapItem.placemark
                    guard let location = placemark.location else {
                        return nil
                    }
                    
                    print("[NearbyCoffeeShops] Found: \(name)")
                    
                    return CoffeeShop(
                        name: name,
                        address: [
                            placemark.thoroughfare,
                            placemark.subThoroughfare
                        ].compactMap { $0 }.joined(separator: " "),
                        city: placemark.locality ?? "",
                        state: placemark.administrativeArea ?? "",
                        zipCode: placemark.postalCode ?? "",
                        location: Location(coordinate: location.coordinate),
                        phoneNumber: mapItem.phoneNumber,
                        website: mapItem.url?.absoluteString
                    )
                }
                
                allShops.append(contentsOf: shops)
                
                // Small delay between searches to avoid rate limiting
                try? await Task.sleep(nanoseconds: 250_000_000) // 0.25 seconds
            } catch {
                // Continue with other queries if one fails
                print("[NearbyCoffeeShops] Search for '\(query)' failed: \(error.localizedDescription)")
            }
        }
        
        print("[NearbyCoffeeShops] Total shops before deduplication: \(allShops.count)")
        
        // Deduplicate by name and location (within 50 meters)
        let deduplicated = deduplicateShops(allShops)
        print("[NearbyCoffeeShops] Unique shops after deduplication: \(deduplicated.count)")
        
        return deduplicated
    }
    
    private func deduplicateShops(_ shops: [CoffeeShop]) -> [CoffeeShop] {
        var uniqueShops: [CoffeeShop] = []
        
        for shop in shops {
            let isDuplicate = uniqueShops.contains { existing in
                // Check if same name
                if existing.name == shop.name {
                    return true
                }
                
                // Check if very close location (within 50 meters)
                let existingLocation = CLLocation(
                    latitude: existing.location.latitude,
                    longitude: existing.location.longitude
                )
                let shopLocation = CLLocation(
                    latitude: shop.location.latitude,
                    longitude: shop.location.longitude
                )
                
                return existingLocation.distance(from: shopLocation) < 50
            }
            
            if !isDuplicate {
                uniqueShops.append(shop)
            }
        }
        
        return uniqueShops
    }
}

// MARK: - Preview

#Preview {
    NearbyCoffeeShopsView(selectedCafeName: .constant(""))
}
