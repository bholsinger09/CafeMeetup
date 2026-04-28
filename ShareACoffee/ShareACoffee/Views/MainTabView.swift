import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var blogViewModel = BlogViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showQRScanner = false
    
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
                            Label("Study Spots", systemImage: "map.fill")
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
                .overlay(alignment: .topTrailing) {
                    // QR Scanner Button (Top Right)
                    Button(action: { showQRScanner = true }) {
                        ZStack {
                            Circle()
                                .fill(themeManager.currentTheme.accentColor.gradient)
                                .frame(width: 50, height: 50)
                                .shadow(color: themeManager.currentTheme.accentColor.opacity(0.4), radius: 8, x: 0, y: 2)
                            
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 50)
                }
                .fullScreenCover(isPresented: $showQRScanner) {
                    QRCodeScannerView()
                }
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
                Label("Study Spots", systemImage: "map.fill")
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
