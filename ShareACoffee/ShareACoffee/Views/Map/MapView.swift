import SwiftUI
import MapKit

// Helper struct for map annotations
struct MapAnnotationData: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isCurrentUser: Bool
    let user: User?
}

struct MapView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedUser: User?
    @State private var showARCafeFinder = false
    
    // Combine current user location and other users into annotations
    private var allMapAnnotations: [MapAnnotationData] {
        var annotations: [MapAnnotationData] = []
        
        // Add current user's location
        if let currentLocation = mapViewModel.currentUserLocation {
            print("[MapView] Adding current user marker at: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
            annotations.append(MapAnnotationData(
                coordinate: currentLocation.coordinate,
                isCurrentUser: true,
                user: nil
            ))
        } else {
            print("[MapView] No current user location available")
        }
        
        // Add other users
        for user in mapViewModel.users {
            if let location = user.location {
                annotations.append(MapAnnotationData(
                    coordinate: location.coordinate,
                    isCurrentUser: false,
                    user: user
                ))
            }
        }
        
        print("[MapView] Total annotations: \(annotations.count)")
        return annotations
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: .constant(.region(mapViewModel.region))) {
                    // User annotations
                    ForEach(allMapAnnotations) { annotation in
                        if annotation.isCurrentUser {
                            Annotation("You", coordinate: annotation.coordinate) {
                                CurrentUserMarker()
                            }
                        } else if let user = annotation.user {
                            Annotation(user.fullName, coordinate: annotation.coordinate) {
                                OtherUserMapMarker(user: user)
                                    .onTapGesture {
                                        selectedUser = user
                                    }
                            }
                        }
                    }
                    
                    // Coffee shop annotations
                    ForEach(mapViewModel.nearbyCoffeeShops) { shop in
                        Annotation(shop.name, coordinate: shop.location.coordinate) {
                            CoffeeShopMarker(shop: shop)
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            Button {
                                Task {
                                    await mapViewModel.centerOnCurrentLocation()
                                }
                            } label: {
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.accentGradient)
                                    .clipShape(Circle())
                                    .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                            }
                            
                            Button {
                                Task {
                                    if let currentUser = authViewModel.currentUser {
                                        await mapViewModel.fetchNearbyUsers(city: currentUser.city, state: currentUser.state, currentUserId: currentUser.id)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.accentGradient)
                                    .clipShape(Circle())
                                    .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                            }
                            
                            // AR Cafe Finder button
                            Button {
                                showARCafeFinder = true
                            } label: {
                                Image(systemName: "arkit")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: Color.purple.opacity(0.3), radius: 8)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Nearby Students")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .sheet(item: $selectedUser) { user in
                UserDetailSheet(user: user)
            }
            .fullScreenCover(isPresented: $showARCafeFinder) {
                if let userLocation = mapViewModel.currentUserLocation?.coordinate {
                    ARCafeFinderView(
                        cafes: mapViewModel.nearbyCoffeeShops,
                        userLocation: userLocation
                    )
                }
            }
            .task {
                print("[MapView] Task started")
                
                // Request permission first
                mapViewModel.requestLocationPermission()
                
                // Give time for user to grant permission (iOS shows dialog)
                print("[MapView] Waiting for permission...")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                // Get current location and center map
                print("[MapView] Starting location tracking...")
                await mapViewModel.startTrackingLocation()
                
                // Give it another moment to stabilize
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // Fetch nearby coffee shops
                print("[MapView] Fetching nearby coffee shops...")
                await mapViewModel.fetchNearbyCoffeeShops()
                
                // Then fetch nearby users if we have a current user
                if let currentUser = authViewModel.currentUser {
                    print("[MapView] Fetching nearby users for \\(currentUser.city), \\(currentUser.state)")
                    await mapViewModel.fetchNearbyUsers(city: currentUser.city, state: currentUser.state, currentUserId: currentUser.id)
                } else {
                    print("[MapView] No current user, skipping nearby users fetch")
                }
            }
            .overlay {
                if mapViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

// Current user marker - distinctive design
struct CurrentUserMarker: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Outer pulsing circle
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: isPulsing ? 80 : 60, height: isPulsing ? 80 : 60)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            
            // Middle circle
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 40, height: 40)
            
            // Inner solid circle
            Circle()
                .fill(Color.blue)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: Color.blue.opacity(0.7), radius: 10)
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// Other users marker - shows user's avatar
struct OtherUserMapMarker: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.avatar.emoji)
                        .font(.system(size: 24))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: Color.yellow.opacity(0.5), radius: 8)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.yellow)
                .offset(y: -5)
        }
    }
}

// Deprecated - kept for compatibility
struct UserMapMarker: View {
    let user: User
    
    var body: some View {
        OtherUserMapMarker(user: user)
    }
}

struct UserDetailSheet: View {
    let user: User
    @Environment(\.dismiss) var dismiss
    @State private var showingConnectionConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image / Avatar
                    Circle()
                        .fill(Color.primaryGradient)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(user.avatar.emoji)
                                .font(.system(size: 50))
                        )
                        .shadow(color: Color.primaryPink.opacity(0.3), radius: 12)
                    
                    // Name and College
                    VStack(spacing: 4) {
                        Text(user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(user.college)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(icon: "location.fill", title: "Location", value: "\(user.city), \(user.state)")
                        
                        DetailRow(icon: "cup.and.saucer.fill", title: "Favorite Coffee", value: user.favoriteCoffee)
                        
                        DetailRow(icon: "building.2.fill", title: "Favorite Shop", value: user.favoriteCoffeeShop)
                        
                        if let bio = user.bio, !bio.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.primaryPink)
                                    Text("About")
                                        .font(.headline)
                                }
                                
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.darkSecondary)
                    .cornerRadius(12)
                    .shadow(color: Color.primaryPink.opacity(0.1), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Action Button
                    Button {
                        showingConnectionConfirmation = true
                    } label: {
                        Text("Connect")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentGradient)
                            .cornerRadius(12)
                            .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                    }
                }
                .padding()
            }
            .background(Color.backgroundGradient)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primaryPink)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

// Coffee Shop marker
struct CoffeeShopMarker: View {
    let shop: CoffeeShop
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.brown)
                    .frame(width: 36, height: 36)
                
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
        }
    }
}

#Preview {
    MapView()
        .environmentObject(MapViewModel())
        .environmentObject(AuthenticationViewModel())
}
