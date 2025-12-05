import SwiftUI
import CoreLocation

/// Detailed Match Profile View - Shows profile, actions, and new LatteLink features
struct MatchProfileView: View {
    let user: User
    let match: Match
    @StateObject private var experienceService = CoffeeExperienceService.shared
    @Environment(\.dismiss) var dismiss
    @State private var showChat = false
    @State private var showCreateStudySession = false
    @State private var showCheckInSheet = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header
                    ProfileHeaderSection(user: user, match: match)
                    
                    // Action Buttons
                    ActionButtonsSection(
                        showChat: $showChat,
                        showCreateStudySession: $showCreateStudySession,
                        showCheckInSheet: $showCheckInSheet
                    )
                    .padding()
                    
                    // Tab Selector
                    Picker("View", selection: $selectedTab) {
                        Text("Profile").tag(0)
                        Text("Activity").tag(1)
                        Text("Study").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        ProfileDetailsSection(user: user)
                    } else if selectedTab == 1 {
                        ActivitySection(matchId: match.id)
                    } else {
                        StudyTogetherSection(userId: user.id)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showChat) {
                ChatView(otherUser: user)
            }
            .sheet(isPresented: $showCreateStudySession) {
                CreateStudySessionView()
            }
            .sheet(isPresented: $showCheckInSheet) {
                CheckInView(matchId: match.id, matchName: user.fullName)
            }
        }
    }
}

// MARK: - Profile Header Section

struct ProfileHeaderSection: View {
    let user: User
    let match: Match
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [Color.purple, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)
            
            VStack(spacing: 12) {
                // Profile Image
                if let profileImageURL = user.profileImageURL,
                   let uiImage = UIImage.fromBase64String(profileImageURL) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(radius: 10)
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(user.fullName.prefix(1))
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.purple)
                        )
                        .shadow(radius: 10)
                }
                
                // Name & Info
                VStack(spacing: 4) {
                    Text(user.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        if let major = user.major {
                            Label(major, systemImage: "graduationcap.fill")
                        }
                        if let year = user.graduationYear {
                            Text("'\(String(year % 100))")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    
                    Text(user.college)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Action Buttons Section

struct ActionButtonsSection: View {
    @Binding var showChat: Bool
    @Binding var showCreateStudySession: Bool
    @Binding var showCheckInSheet: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Message Button
            Button(action: { showChat = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "message.fill")
                        .font(.title2)
                    Text("Message")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Study Session Button (NEW FEATURE)
            Button(action: { showCreateStudySession = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "book.fill")
                        .font(.title2)
                    Text("Study")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Check-In Button (NEW FEATURE)
            Button(action: { showCheckInSheet = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.title2)
                    Text("Check In")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Profile Details Section

struct ProfileDetailsSection: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            // Bio
            if let bio = user.bio, !bio.isEmpty {
                InfoCard(title: "About") {
                    Text(bio)
                        .font(.body)
                }
            }
            
            // Coffee Preferences
            InfoCard(title: "☕ Coffee Vibes") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.brown)
                        Text("Favorite: \(user.favoriteCoffee)")
                    }
                    
                    HStack {
                        Image(systemName: "storefront.fill")
                            .foregroundColor(.orange)
                        Text("Go-to spot: \(user.favoriteCoffeeShop)")
                    }
                }
            }
            
            // Academic Info
            if user.major != nil || user.studyPreferences != nil {
                InfoCard(title: "🎓 Academic") {
                    VStack(alignment: .leading, spacing: 8) {
                        if let major = user.major {
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.blue)
                                Text("Major: \(major)")
                            }
                        }
                        
                        if let prefs = user.studyPreferences, !prefs.isEmpty {
                            HStack(alignment: .top) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                VStack(alignment: .leading) {
                                    Text("Study Interests:")
                                        .fontWeight(.semibold)
                                    Text(prefs.joined(separator: ", "))
                                }
                            }
                        }
                    }
                }
            }
            
            // Location
            InfoCard(title: "📍 Location") {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text("\(user.city), \(user.state)")
                }
            }
        }
        .padding()
    }
}

// MARK: - Activity Section (NEW FEATURE)

struct ActivitySection: View {
    let matchId: String
    @StateObject private var experienceService = CoffeeExperienceService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Check-In History
            let checkIns = experienceService.getCheckInsWithMatch(matchId)
            
            if checkIns.isEmpty {
                EmptyStateView(
                    icon: "location.circle",
                    title: "No Check-Ins Yet",
                    message: "Start your coffee date journey! Check in together at a café to earn rewards."
                )
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("📍 Check-In History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(checkIns) { checkIn in
                        CheckInHistoryCard(checkIn: checkIn)
                    }
                }
                .padding()
            }
            
            // Earned Badges Together
            InfoCard(title: "🏆 Achievements Together") {
                Text("Check in at 3 cafés together to unlock the 'Coffee Date Pro' badge!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
}

struct CheckInHistoryCard: View {
    let checkIn: CafeCheckIn
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .foregroundColor(.brown)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(checkIn.cafeName)
                    .font(.headline)
                
                Text(checkIn.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let coffee = checkIn.coffeeOrdered {
                    Text("☕️ \(coffee)")
                        .font(.caption)
                        .foregroundColor(.brown)
                }
                
                if let rating = checkIn.rating {
                    HStack(spacing: 2) {
                        ForEach(0..<rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                        }
                    }
                }
            }
            
            Spacer()
            
            Text("+30 pts")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Study Together Section (NEW FEATURE)

struct StudyTogetherSection: View {
    let userId: String
    @StateObject private var experienceService = CoffeeExperienceService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Upcoming Study Sessions
            let upcomingSessions = experienceService.getUpcomingSessions(forUserId: userId)
            
            if upcomingSessions.isEmpty {
                VStack(spacing: 20) {
                    EmptyStateView(
                        icon: "book.circle",
                        title: "No Study Sessions",
                        message: "Create a study session together to combine academics with romance!"
                    )
                    
                    Text("💡 Study sessions are a great way to spend time together while being productive!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("📚 Upcoming Study Sessions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(upcomingSessions) { session in
                        StudySessionCard(session: session)
                    }
                }
                .padding()
            }
            
            // Study Tips
            InfoCard(title: "💡 Study Date Ideas") {
                VStack(alignment: .leading, spacing: 8) {
                    StudyTip(icon: "☕️", text: "Start with coffee, review notes together")
                    StudyTip(icon: "📱", text: "Quiz each other on flashcards")
                    StudyTip(icon: "🎯", text: "Set goals and reward with treats")
                    StudyTip(icon: "⏰", text: "Use Pomodoro: 25min study, 5min chat")
                }
            }
            .padding(.horizontal)
        }
    }
}

struct StudyTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Text(icon)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Check-In View (NEW FEATURE)

struct CheckInView: View {
    let matchId: String
    let matchName: String
    @Environment(\.dismiss) var dismiss
    @StateObject private var experienceService = CoffeeExperienceService.shared
    @State private var selectedCafe = "The Human Bean"
    @State private var coffeeOrdered = ""
    @State private var rating = 5
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Location") {
                    TextField("Coffee Shop", text: $selectedCafe)
                }
                
                Section("Your Order") {
                    TextField("What did you get?", text: $coffeeOrdered)
                        .placeholder("e.g., Vanilla Latte")
                }
                
                Section("How was it?") {
                    HStack {
                        Text("Rating")
                        Spacer()
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: { rating = star }) {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .foregroundColor(star <= rating ? .yellow : .gray)
                                }
                            }
                        }
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Text("🎉 You'll earn 30 points for checking in with \(matchName)!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Check In") {
                        checkIn()
                    }
                    .disabled(selectedCafe.isEmpty)
                }
            }
        }
    }
    
    private func checkIn() {
        Task {
            try? await experienceService.checkIn(
                userId: "current_user",
                cafeId: "cafe1",
                cafeName: selectedCafe,
                location: CLLocationCoordinate2D(latitude: 43.6150, longitude: -116.2023),
                matchId: matchId,
                coffeeOrdered: coffeeOrdered.isEmpty ? nil : coffeeOrdered
            )
            dismiss()
        }
    }
}

// MARK: - Helper Views

struct InfoCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

extension View {
    func placeholder(_ text: String) -> some View {
        self.overlay(alignment: .leading) {
            if let textField = self as? TextField<Text> {
                Text(text)
                    .foregroundColor(.gray)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    MatchProfileView(
        user: User(
            email: "test@test.com",
            fullName: "Sarah Johnson",
            college: "Boise State University",
            major: "Computer Science",
            graduationYear: 2026,
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Vanilla Latte",
            favoriteCoffeeShop: "The Human Bean",
            bio: "Coffee enthusiast and CS major. Love studying at cafés!",
            studyPreferences: ["Computer Science", "Mathematics"]
        ),
        match: Match(userId1: "1", userId2: "2")
    )
}
