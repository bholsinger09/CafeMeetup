import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var blogViewModel = BlogViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some View {
        TabView {
            // PRIMARY TAB: Study Sessions (emphasizes academic collaboration)
            StudySessionsView(userId: authViewModel.currentUser?.id ?? "")
                .tabItem {
                    Label("Study Sessions", systemImage: "book.fill")
                }
            
            // Academic Progress Dashboard
            AcademicDashboardView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
            
            // Map (now emphasizes study locations)
            MapView()
                .environmentObject(mapViewModel)
                .tabItem {
                    Label("Study Spots", systemImage: "map.fill")
                }
            
            // Blog Feed (academic content)
            BlogFeedView()
                .environmentObject(blogViewModel)
                .tabItem {
                    Label("Feed", systemImage: "newspaper.fill")
                }
            
            // Profile (now includes My Classes)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.brown)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
}
