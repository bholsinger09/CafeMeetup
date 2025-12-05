import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedUser: User?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $mapViewModel.region, annotationItems: mapViewModel.users) { user in
                    MapAnnotation(coordinate: user.location?.coordinate ?? CLLocationCoordinate2D()) {
                        UserMapMarker(user: user)
                            .onTapGesture {
                                selectedUser = user
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
                                    .background(Color.brown)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            
                            Button {
                                Task {
                                    if let currentUser = authViewModel.currentUser {
                                        await mapViewModel.fetchNearbyUsers(city: currentUser.city, state: currentUser.state)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.brown)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Nearby Students")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedUser) { user in
                UserDetailSheet(user: user)
            }
            .task {
                mapViewModel.requestLocationPermission()
                
                if let currentUser = authViewModel.currentUser {
                    await mapViewModel.fetchNearbyUsers(city: currentUser.city, state: currentUser.state)
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

struct UserMapMarker: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color.brown)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.fullName.prefix(1))
                        .font(.headline)
                        .foregroundColor(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.brown)
                .offset(y: -5)
        }
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
                    // Profile Image
                    Circle()
                        .fill(Color.brown.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(user.fullName.prefix(1))
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.brown)
                        )
                    
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
                                        .foregroundColor(.brown)
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
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Action Button
                    Button {
                        showingConnectionConfirmation = true
                    } label: {
                        Text("Connect")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Send Connection Request?", isPresented: $showingConnectionConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Send Request") {
                    // Connection request sent - would integrate with backend
                    dismiss()
                }
            } message: {
                Text("Send a connection request to \(user.fullName)? You'll be able to chat and plan coffee dates if they accept.")
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
                .foregroundColor(.brown)
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

#Preview {
    MapView()
        .environmentObject(MapViewModel())
        .environmentObject(AuthenticationViewModel())
}
