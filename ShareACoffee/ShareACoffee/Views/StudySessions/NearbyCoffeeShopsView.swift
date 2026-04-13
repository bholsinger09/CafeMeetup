import SwiftUI
import CoreLocation
import MapKit
import Combine

struct NearbyCoffeeShopsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCafeName: String
    
    @StateObject private var viewModel = NearbyCoffeeShopsViewModel()
    
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
                Text("Showing \(viewModel.nearbyCoffeeShops.count) coffee shops within 15 miles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ForEach(viewModel.nearbyCoffeeShops) { shop in
                Button(action: {
                    selectedCafeName = shop.name
                    dismiss()
                }) {
                    CoffeeShopRow(shop: shop)
                }
            }
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
            
            Text("No coffee shops found within 15 miles of your location. Try expanding your search area.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
    
    private let locationService = LocationService.shared
    private let radiusMiles: Double = 15.0
    
    func checkLocationPermissionAndFetch() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            isRequestingPermission = true
        case .restricted, .denied:
            errorMessage = "Location access is required to find nearby coffee shops. Please enable location access in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            Task {
                await fetchNearbyCoffeeShops()
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
            self.nearbyCoffeeShops = coffeeShops
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
            
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch nearby coffee shops: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func searchNearbyCoffeeShops(near coordinate: CLLocationCoordinate2D) async throws -> [CoffeeShop] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "coffee shop"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radiusMiles * 1609.34 * 2,
            longitudinalMeters: radiusMiles * 1609.34 * 2
        )
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems.compactMap { mapItem in
            guard let name = mapItem.name,
                  let location = mapItem.placemark.location else {
                return nil
            }
            
            return CoffeeShop(
                name: name,
                address: [
                    mapItem.placemark.thoroughfare,
                    mapItem.placemark.subThoroughfare
                ].compactMap { $0 }.joined(separator: " "),
                city: mapItem.placemark.locality ?? "",
                state: mapItem.placemark.administrativeArea ?? "",
                zipCode: mapItem.placemark.postalCode ?? "",
                location: Location(coordinate: location.coordinate),
                phoneNumber: mapItem.phoneNumber,
                website: mapItem.url?.absoluteString
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NearbyCoffeeShopsView(selectedCafeName: .constant(""))
}
