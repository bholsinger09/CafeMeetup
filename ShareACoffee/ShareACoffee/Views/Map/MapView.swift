import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeAuth
import ShareACoffeeStudy
import ShareACoffeeCoffee
import ShareACoffeeSocial
import ShareACoffeeBlog
import ShareACoffeeDiscovery
import ShareACoffeeProfile
import MapKit

// MARK: - Map Annotation Data

struct MapAnnotationData: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isCurrentUser: Bool
    let user: User?
}

// MARK: - Main MapView

struct MapView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @State private var selectedUser: User?
    @State private var showARCafeFinder = false
    @State private var showCoffeeShopList = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var cachedAnnotations: [MapAnnotationData] = []
    @State private var cachedCoffeeShops: [CoffeeShop] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                mapContent
                overlayControls
            }
            .navigationTitle("Nearby Students")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .sheet(item: $selectedUser) { user in
                UserDetailSheet(user: user)
            }
            .fullScreenCover(isPresented: $showARCafeFinder) {
                if let userLocation = cachedAnnotations.first(where: { $0.isCurrentUser })?.coordinate {
                    ARCafeFinderView(
                        cafes: cachedCoffeeShops,
                        userLocation: userLocation
                    )
                }
            }
            .sheet(isPresented: $showCoffeeShopList) {
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
            if let currentAnnotation = cachedAnnotations.first(where: { $0.isCurrentUser }) {
                Annotation("You", coordinate: currentAnnotation.coordinate) {
                    CurrentUserMarker()
                }
            }
            
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
            
            ForEach(cachedCoffeeShops) { shop in
                Marker(shop.name, systemImage: "cup.and.saucer.fill", coordinate: shop.location.coordinate)
                    .tint(.brown)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Overlay Controls
    
    @ViewBuilder
    private var overlayControls: some View {
        VStack {
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
            
            HStack {
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: handleCenterLocation) {
                        Image(systemName: "location.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.primaryPink)
                            .clipShape(Circle())
                    }
                    
                    Button(action: handleRefreshUsers) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.primaryPink)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { showARCafeFinder = true }) {
                        Image(systemName: "arkit")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.purple)
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Data Management
    
    private func updateCachedData() {
        cachedAnnotations = buildAnnotations()
        cachedCoffeeShops = getCoffeeShops()
    }
    
    private func buildAnnotations() -> [MapAnnotationData] {
        var annotations: [MapAnnotationData] = []
        
        if let currentLocation = getCurrentUserLocation() {
            annotations.append(MapAnnotationData(
                coordinate: currentLocation,
                isCurrentUser: true,
                user: nil
            ))
        }
        
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
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await mapViewModel.requestLocationUpdate()
        updateCachedData()
    }
}

// MARK: - Current User Marker

struct CurrentUserMarker: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: isPulsing ? 80 : 60, height: isPulsing ? 80 : 60)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 40, height: 40)
            
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

// MARK: - Other User Marker

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

// MARK: - Placeholder Components

struct UserDetailSheet: View {
    let user: User
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 16) {
                    Text(user.avatar.emoji)
                        .font(.system(size: 80))
                    
                    Text(user.fullName)
                        .font(.title2.weight(.bold))
                    
                    if !user.major.isEmpty {
                        Text(user.major)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct CoffeeShopListSheet: View {
    let coffeeShops: [CoffeeShop]
    let onSelectShop: (CoffeeShop) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(coffeeShops) { shop in
                Button(action: { onSelectShop(shop) }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shop.name)
                            .font(.headline)
                        Text(shop.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Coffee Shops")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
