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
            
            StudySessionsPlaceholder()
                .tabItem {
                    Label("Study", systemImage: "book.fill")
                }
            
            RewardsPlaceholder()
                .tabItem {
                    Label("Rewards", systemImage: "star.fill")
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

// MARK: - Placeholder Views (until files are added to Xcode project)

struct StudySessionsPlaceholder: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                Text("Study Sessions")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Browse and create study sessions with your matches")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureItem(icon: "graduationcap.fill", text: "Choose your subject", color: .blue)
                    FeatureItem(icon: "calendar", text: "Schedule study dates", color: .green)
                    FeatureItem(icon: "person.2.fill", text: "Study together, earn points", color: .orange)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationTitle("Study Sessions")
        }
    }
}

struct RewardsPlaceholder: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                    
                    Text("Rewards & Badges")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Track your progress and unlock achievements")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        RewardFeatureCard(
                            icon: "flame.fill",
                            title: "Build Streaks",
                            description: "Meet regularly to build your streak",
                            color: .orange
                        )
                        
                        RewardFeatureCard(
                            icon: "trophy.fill",
                            title: "Unlock Badges",
                            description: "Earn 15+ unique coffee badges",
                            color: .yellow
                        )
                        
                        RewardFeatureCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Level Up",
                            description: "Gain XP and reach Coffee Legend status",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Rewards")
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(text)
                .font(.body)
        }
    }
}

struct RewardFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
}
