import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var blogViewModel = BlogViewModel()
    @StateObject private var mapViewModel = MapViewModel()
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
                .accentColor(.brown)
                .overlay(alignment: .bottomTrailing) {
                    // Floating QR Scanner Button
                    Button(action: { showQRScanner = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
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
