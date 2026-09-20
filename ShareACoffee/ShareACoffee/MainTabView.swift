import SwiftUI
import ShareACoffeeCore
import ShareACoffeeAuth

public struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        TabView {
            // Discovery Tab
            DiscoveryTabView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
            
            // Study Sessions Tab
            StudySessionsTabView()
                .tabItem {
                    Label("Study", systemImage: "books.vertical")
                }
            
            // Messages Tab
            MessagesTabView()
                .tabItem {
                    Label("Messages", systemImage: "bubble.left")
                }
            
            // Matches Tab
            MatchesTabView()
                .tabItem {
                    Label("Matches", systemImage: "heart")
                }
            
            // Profile Tab
            ProfileTabView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Tab Views

struct DiscoveryTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Discovery")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Discover Study Buddies")
        }
    }
}

struct StudySessionsTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Study Sessions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Study Sessions")
        }
    }
}

struct MessagesTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Messages")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Messages")
        }
    }
}

struct MatchesTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Matches")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Your Matches")
        }
    }
}

struct ProfileTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                if let user = authViewModel.currentUser {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name: \(user.fullName)")
                        Text("Email: \(user.email)")
                        Text("City: \(user.city), \(user.state)")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    Task {
                        await authViewModel.signOut()
                    }
                }) {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("My Profile")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(ThemeManager.shared)
}
