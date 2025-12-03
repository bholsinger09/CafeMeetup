import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var blogViewModel = BlogViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some View {
        TabView {
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
        .accentColor(.brown)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
}
