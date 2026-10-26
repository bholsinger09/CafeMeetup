import SwiftUI
import ShareACoffeeCore
import ShareACoffeeAuth
import ShareACoffeeStudy
import ShareACoffeeCoffee
import ShareACoffeeSocial
import ShareACoffeeBlog
import ShareACoffeeDiscovery
import ShareACoffeeProfile

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var blogViewModel = BlogViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad layout with sidebar
                NavigationSplitView(columnVisibility: .constant(.detailOnly)) {
                    sidebarContent
                } detail: {
                    StudySessionsView(userId: authViewModel.currentUser?.id ?? "")
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                // iPhone layout with tab bar
                TabView {
                    // PRIMARY TAB: Study Sessions (emphasizes academic collaboration)
                    NavigationStack {
                        StudySessionsView(userId: authViewModel.currentUser?.id ?? "")
                        }
                        .tabItem {
                            Label("Study Sessions", systemImage: "book.fill")
                        }
                        .toolbarBackground(themeManager.currentTheme.cardBackgroundColor, for: .tabBar)
                        .toolbarBackground(.visible, for: .tabBar)
                        
                    // Study Roadmap - Goal Tracking
                        NavigationStack {
                        StudyRoadmapView(userId: authViewModel.currentUser?.id ?? "")
                        }
                        .tabItem {
                        Label("Roadmap", systemImage: "map.fill")
                        }
                        
                    // ML-Powered Study Buddy Recommendations
                        NavigationStack {
                        StudyBuddyRecommendationView()
                        }
                        .tabItem {
                        Label("Discover", systemImage: "person.2.fill")
                        }
                        
                    // Academic Progress Dashboard
                    NavigationStack {
                        AcademicDashboardView()
                    }
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                        
                    // Map (now emphasizes study locations)
                    MapView()
                        .environmentObject(mapViewModel)
                        .tabItem {
                            Label("Study Spots", systemImage: "location.fill")
                        }
                        
                    // Blog Feed (academic content)
                    NavigationStack {
                        BlogFeedView()
                            .environmentObject(blogViewModel)
                        }
                        .tabItem {
                        Label("Feed", systemImage: "newspaper.fill")
                        }
                        
                    // Profile (now includes My Classes)
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                }
                    .accentColor(themeManager.currentTheme.accentColor)
                    .background(
                        themeManager.currentTheme.primaryGradient
                            .ignoresSafeArea()
                    )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private var sidebarContent: some View {
        List {
            NavigationLink {
                StudySessionsView(userId: authViewModel.currentUser?.id ?? "")
            } label: {
                Label("Study Sessions", systemImage: "book.fill")
            }
            
            NavigationLink {
                StudyRoadmapView(userId: authViewModel.currentUser?.id ?? "")
            } label: {
                Label("Roadmap", systemImage: "map.fill")
            }
            
            NavigationLink {
                StudyBuddyRecommendationView()
            } label: {
                Label("Discover", systemImage: "person.2.fill")
            }
            
            NavigationLink {
                AcademicDashboardView()
            } label: {
                Label("Progress", systemImage: "chart.bar.fill")
            }
            
            NavigationLink {
                MapView()
                    .environmentObject(mapViewModel)
            } label: {
                Label("Study Spots", systemImage: "location.fill")
            }
            
            NavigationLink {
                BlogFeedView()
                    .environmentObject(blogViewModel)
            } label: {
                Label("Feed", systemImage: "newspaper.fill")
            }
            
            NavigationLink {
                ProfileView()
            } label: {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .navigationTitle("ShareACoffee")
        .listStyle(.sidebar)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
}
