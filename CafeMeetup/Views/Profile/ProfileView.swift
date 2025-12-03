import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showEditProfile = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.brown.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(authViewModel.currentUser?.fullName.prefix(1) ?? "?")
                                    .font(.system(size: 40, weight: .semibold))
                                    .foregroundColor(.brown)
                            )
                        
                        VStack(spacing: 4) {
                            Text(authViewModel.currentUser?.fullName ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(authViewModel.currentUser?.college ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Edit Profile") {
                            showEditProfile = true
                        }
                        .buttonStyle(.bordered)
                        .tint(.brown)
                    }
                    .padding()
                    
                    // Profile Details
                    VStack(spacing: 0) {
                        ProfileDetailRow(icon: "envelope.fill", title: "Email", value: authViewModel.currentUser?.email ?? "")
                        
                        Divider().padding(.leading, 50)
                        
                        ProfileDetailRow(icon: "location.fill", title: "Location", value: "\(authViewModel.currentUser?.city ?? ""), \(authViewModel.currentUser?.state ?? "")")
                        
                        Divider().padding(.leading, 50)
                        
                        ProfileDetailRow(icon: "cup.and.saucer.fill", title: "Favorite Coffee", value: authViewModel.currentUser?.favoriteCoffee ?? "")
                        
                        Divider().padding(.leading, 50)
                        
                        ProfileDetailRow(icon: "building.2.fill", title: "Favorite Shop", value: authViewModel.currentUser?.favoriteCoffeeShop ?? "")
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Me")
                                .font(.headline)
                            
                            Text(bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Sign Out Button
                    Button {
                        showSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.brown)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
}
