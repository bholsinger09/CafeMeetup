import SwiftUI
import ShareACoffeeCore
import ShareACoffeeAuth
import ShareACoffeeStudy
import ShareACoffeeCoffee
import ShareACoffeeSocial
import ShareACoffeeBlog
import ShareACoffeeDiscovery
import ShareACoffeeProfile
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
    @State private var showCoffeeShopList = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Cache ViewModel data to avoid dynamic member access in complex contexts
    @State private var cachedAnnotations: [MapAnnotationData] = []
    @State private var cachedCoffeeShops: [CoffeeShop] = []
    
    // MARK: - View Builder
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map with cached data
                mapContent
                
                // Overlay controls
                overlayControls
            }
            .navigationTitle("Nearby Students")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .sheet(item: $selectedUser) { user in
                UserDetailSheet(user: user)
            }
            .fullScreenCover(isPresented: $showARCafeFinder) {
                arFinderContent
            }
            .sheet(isPresented: $showCoffeeShopList) {
                coffeeShopListContent
            }
            .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
                updateCachedData()
            }
            .task {
                await initializeMap()
            }
        }
    }
    
    // MARK: - Map Content
    
    @ViewBuilder
    private var mapContent: some View {
        Map(position: $cameraPosition) {
            // Current user marker
            if let currentAnnotation = cachedAnnotations.first(where: { $0.isCurrentUser }) {
                Annotation("You", coordinate: currentAnnotation.coordinate) {
                    CurrentUserMarker()
                }
            }
            
            // Other user markers
            ForEach(cachedAnnotations.filter { !$0.isCurrentUser }) { annotation in
                if let user = annotation.user {
                    Annotation(user.fullName, coordinate: annotation.coordinate) {
                        OtherUserMapMarker(user: user)
                            .onTapGesture {
                                selectedUser = user
                            }
                    }
                }
            }
            
            // Coffee shop markers
            ForEach(cachedCoffeeShops) { shop in
                Marker(shop.name, systemImage: "cup.and.saucer.fill", coordinate: shop.location.coordinate)
                    .tint(.brown)
            }
        }
        .ignoresSafeArea()
        .onChange(of: cameraPosition) { _, _ in
            // Track camera changes if needed
        }
    }
    
    // MARK: - Overlay Controls
    
    @ViewBuilder
    private var overlayControls: some View {
        VStack {
            // Top coffee shop button
            HStack {
                Button(action: { showCoffeeShopList = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.caption)
                        Text("Coffee Shops: \(cachedCoffeeShops.count)")
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.brown)
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            // Right side buttons
            HStack {
                Spacer()
                
                VStack(spacing: 12) {
                    // Location button
                    Button(action: handleCenterLocation) {
                        Image(systemName: "location.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.primaryGradient)
                            .clipShape(Circle())
                            .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                    }
                    
                    // Refresh button
                    Button(action: handleRefreshUsers) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.primaryGradient)
                            .clipShape(Circle())
                            .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                    }
                    
                    // AR Finder button
                    Button(action: { showARCafeFinder = true }) {
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
    
    // MARK: - Sheet Contents
    
    @ViewBuilder
    private var arFinderContent: some View {
        if let userLocation = cachedAnnotations.first(where: { $0.isCurrentUser })?.coordinate {
            ARCafeFinderView(
                cafes: cachedCoffeeShops,
                userLocation: userLocation
            )
        }
    }
    
    @ViewBuilder
    private var coffeeShopListContent: some View {
        CoffeeShopListSheet(
            coffeeShops: cachedCoffeeShops,
            onSelectShop: { shop in
                showCoffeeShopList = false
                cameraPosition = .region(MKCoordinateRegion(
                    center: shop.location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        )
    }
    
    // MARK: - Data Updates
    
    private func updateCachedData() {
        // Update cached annotations
        cachedAnnotations = buildAnnotations()
        
        // Update cached coffee shops
        cachedCoffeeShops = getCoffeeShops()
    }
    
    private func buildAnnotations() -> [MapAnnotationData] {
        var annotations: [MapAnnotationData] = []
        
        // Add current user location
        if let currentLocation = getCurrentUserLocation() {
            annotations.append(MapAnnotationData(
                coordinate: currentLocation,
                isCurrentUser: true,
                user: nil
            ))
        }
        
        // Add other users
        for user in getOtherUsers() {
            if let location = user.location {
                annotations.append(MapAnnotationData(
                    coordinate: location.coordinate,
                    isCurrentUser: false,
                    user: user
                ))
            }
        }
        
        return annotations
    }
    
    // MARK: - ViewModel Accessors
    
    private func getCurrentUserLocation() -> CLLocationCoordinate2D? {
        mapViewModel.currentUserLocation
    }
    
    private func getOtherUsers() -> [User] {
        mapViewModel.users
    }
    
    private func getCoffeeShops() -> [CoffeeShop] {
        mapViewModel.nearbyCoffeeShops
    }
    
    // MARK: - Button Actions
    
    private func handleCenterLocation() {
        Task {
            await mapViewModel.centerOnCurrentLocation()
        }
    }
    
    private func handleRefreshUsers() {
        Task {
            if let currentUser = authViewModel.currentUser {
                await mapViewModel.fetchNearbyUsers(
                    city: currentUser.city,
                    state: currentUser.state,
                    currentUserId: currentUser.id
                )
            }
        }
    }
    
    // MARK: - Initialization
    
    private func initializeMap() async {
        mapViewModel.requestLocationPermission()
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        await mapViewModel.requestLocationUpdate()
        updateCachedData()
    }
}

// MARK: - Current User Marker
    
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
                            .background(Color.primaryGradient)
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
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.brown],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
}

// Coffee Shop List Sheet
struct CoffeeShopListSheet: View {
    @Environment(\.dismiss) private var dismiss
    let coffeeShops: [CoffeeShop]
    let onSelectShop: (CoffeeShop) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGradient
                    .ignoresSafeArea()
                
                if coffeeShops.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Coffee Shops Found")
                            .font(.title2.weight(.semibold))
                        
                        Text("Try adjusting your location or search radius")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(coffeeShops) { shop in
                                CoffeeShopListRow(shop: shop) {
                                    onSelectShop(shop)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Nearby Coffee Shops")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryPink)
                }
            }
        }
    }
}

// Coffee Shop Row in List
struct CoffeeShopListRow: View {
    let shop: CoffeeShop
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Coffee icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.brown],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                
                // Shop info
                VStack(alignment: .leading, spacing: 4) {
                    Text(shop.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let distance = shop.distance {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(String(format: "%.2f mi away", distance))
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    if !shop.address.isEmpty || !shop.city.isEmpty {
                        Text([shop.address, shop.city].filter { !$0.isEmpty }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "location.circle.fill")
                    .font(.title3)
                    .foregroundColor(.primaryPink)
            }
            .padding()
            .background(Color.darkSecondary)
            .cornerRadius(12)
            .shadow(color: Color.primaryPink.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MapView()
        .environmentObject(MapViewModel())
        .environmentObject(AuthenticationViewModel())
}
