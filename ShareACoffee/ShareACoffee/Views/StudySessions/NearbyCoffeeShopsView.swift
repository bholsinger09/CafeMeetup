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

// MARK: - Preview

#Preview {
    NearbyCoffeeShopsView(selectedCafeName: .constant(""))
}
