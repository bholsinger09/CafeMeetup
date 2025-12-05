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
            
            StudySessionsTab()
                .tabItem {
                    Label("Study", systemImage: "book.fill")
                }
            
            RewardsTab()
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

// MARK: - Study Sessions Tab

// MARK: - Study Session Model
struct StudySessionItem: Identifiable {
    let id = UUID()
    let subject: String
    let topic: String
    let date: Date
    let duration: Int
    let createdAt: Date
}

struct StudySessionsTab: View {
    @State private var showCreateSession = false
    @State private var selectedSubject: String?
    @State private var sessions: [StudySessionItem] = []
    
    let subjects = ["Computer Science", "Mathematics", "Biology", "Chemistry", "Physics", 
                   "Engineering", "Business", "Psychology", "English", "History", 
                   "Art", "Music", "Languages", "Economics", "Nursing", "Other"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Study & Connect")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Find study partners and turn study sessions into coffee dates")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Create Session Button
                    Button(action: { showCreateSession = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Study Session")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Subject Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(subjects, id: \.self) { subject in
                                Button(action: {
                                    selectedSubject = selectedSubject == subject ? nil : subject
                                }) {
                                    Text(subject)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedSubject == subject ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedSubject == subject ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Study Sessions List
                    if !filteredSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Study Sessions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(filteredSessions) { session in
                                StudySessionCard(session: session)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Info Section
                    VStack(spacing: 16) {
                        InfoBox(
                            icon: "lightbulb.fill",
                            title: "How It Works",
                            description: "Create or join study sessions with your matches. Study together at your favorite café and earn 25 points per session!",
                            color: .yellow
                        )
                        
                        InfoBox(
                            icon: "star.fill",
                            title: "Earn Rewards",
                            description: "Complete study sessions to unlock the Study Buddy badge and level up faster!",
                            color: .orange
                        )
                        
                        InfoBox(
                            icon: "heart.fill",
                            title: "Make Connections",
                            description: "Turn study sessions into coffee dates. Academic success meets romance!",
                            color: .pink
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreateSession) {
                CreateSessionSheet(subjects: subjects) { newSession in
                    sessions.append(newSession)
                }
            }
        }
    }
    
    var filteredSessions: [StudySessionItem] {
        if let subject = selectedSubject {
            return sessions.filter { $0.subject == subject }
        }
        return sessions
    }
}

struct StudySessionCard: View {
    let session: StudySessionItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.subject)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Text(session.topic.isEmpty ? "Study Session" : session.topic)
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(session.duration) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(session.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(session.date, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct InfoBox: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CreateSessionSheet: View {
    let subjects: [String]
    let onCreate: (StudySessionItem) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedSubject = "Computer Science"
    @State private var topic = ""
    @State private var selectedDate = Date()
    @State private var duration = 60
    
    let durations = [30, 60, 90, 120]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Study Details") {
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(subjects, id: \.self) { subject in
                            Text(subject).tag(subject)
                        }
                    }
                    
                    TextField("Topic (e.g., Midterm Review)", text: $topic)
                }
                
                Section("When?") {
                    DatePicker("Date & Time", selection: $selectedDate, in: Date()...)
                    
                    Picker("Duration", selection: $duration) {
                        ForEach(durations, id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                }
                
                Section {
                    Button("Create Study Session") {
                        let newSession = StudySessionItem(
                            subject: selectedSubject,
                            topic: topic,
                            date: selectedDate,
                            duration: duration,
                            createdAt: Date()
                        )
                        onCreate(newSession)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Plan Study Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Rewards Tab

struct RewardsTab: View {
    @State private var selectedTab = 0
    @State private var rewards = MockRewards()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Rewards Summary
                    VStack(spacing: 16) {
                        Text("Level \(rewards.level)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(rewards.levelName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        // Progress
                        VStack(spacing: 4) {
                            HStack {
                                Text("\(rewards.points) points")
                                    .font(.caption)
                                Spacer()
                                Text("\(rewards.pointsToNext) to next level")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.3))
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .pink],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * rewards.progress)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(.horizontal)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            RewardStatCard(icon: "flame.fill", value: "\(rewards.streak)", label: "Day Streak", color: .orange)
                            RewardStatCard(icon: "checkmark.circle.fill", value: "\(rewards.checkIns)", label: "Check-ins", color: .green)
                            RewardStatCard(icon: "star.fill", value: "\(rewards.badgesUnlocked)", label: "Badges", color: .yellow)
                            RewardStatCard(icon: "book.fill", value: "\(rewards.studySessions)", label: "Study Sessions", color: .purple)
                            RewardStatCard(icon: "cup.and.saucer.fill", value: "\(rewards.uniqueCafes)", label: "Unique Cafés", color: .brown)
                            RewardStatCard(icon: "heart.fill", value: "\(rewards.points)", label: "Total Points", color: .pink)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Tabs
                    Picker("View", selection: $selectedTab) {
                        Text("Unlocked (\(rewards.unlockedBadges.count))").tag(0)
                        Text("Locked (\(rewards.lockedBadges.count))").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Badges
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(selectedTab == 0 ? rewards.unlockedBadges : rewards.lockedBadges) { badge in
                            RewardBadgeCard(badge: badge)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Rewards & Badges")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MockRewards {
    let level = 3
    let levelName = "Café Regular"
    let points = 150
    let pointsToNext = 50
    let progress = 0.75
    let streak = 5
    let checkIns = 8
    let badgesUnlocked = 3
    let studySessions = 2
    let uniqueCafes = 3
    
    let unlockedBadges = [
        Badge(id: "first_latte", name: "First Latte", emoji: "☕️", rarity: "Common", description: "Complete your first check-in", isUnlocked: true),
        Badge(id: "social_butterfly", name: "Social Butterfly", emoji: "🦋", rarity: "Common", description: "Match with 5 people", isUnlocked: true),
        Badge(id: "morning_person", name: "Morning Person", emoji: "🌅", rarity: "Rare", description: "Check-in before 9 AM", isUnlocked: true)
    ]
    
    let lockedBadges = [
        Badge(id: "coffee_connoisseur", name: "Coffee Connoisseur", emoji: "🎓", rarity: "Rare", description: "Try 10 different coffee drinks", isUnlocked: false),
        Badge(id: "study_buddy", name: "Study Buddy", emoji: "📚", rarity: "Epic", description: "Complete 5 study sessions", isUnlocked: false),
        Badge(id: "latte_legend", name: "Latte Legend", emoji: "👑", rarity: "Legendary", description: "Reach level 10", isUnlocked: false)
    ]
}

struct Badge: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let rarity: String
    let description: String
    let isUnlocked: Bool
}

struct RewardStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct RewardBadgeCard: View {
    let badge: Badge
    
    var rarityColor: Color {
        switch badge.rarity {
        case "Common": return .gray
        case "Rare": return .blue
        case "Epic": return .purple
        case "Legendary": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? rarityColor : Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
                
                Text(badge.emoji)
                    .font(.system(size: 35))
                    .grayscale(badge.isUnlocked ? 0 : 1)
                    .opacity(badge.isUnlocked ? 1 : 0.5)
            }
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.rarity)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(rarityColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(rarityColor.opacity(0.2))
                    .cornerRadius(4)
                
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 2)
                
                if !badge.isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                        Text("Locked")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 4)
                }
            }
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
