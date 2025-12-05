import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var blogViewModel = BlogViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some View {
        TabView {
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: "heart.circle.fill")
                }
            
            MatchesView()
                .tabItem {
                    Label("Matches", systemImage: "message.fill")
                }
            
            BlogFeedView()
                .environmentObject(blogViewModel)
                .tabItem {
                    Label("Feed", systemImage: "newspaper.fill")
                }
            
            MapView()
                .environmentObject(mapViewModel)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(Color(red: 0.85, green: 0.65, blue: 0.75))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
}
