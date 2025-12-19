import SwiftUI
import CoreLocation

/// Detailed Match Profile View - Shows profile and actions
struct MatchProfileView: View {
    let user: User
    let match: Match
    @Environment(\.dismiss) var dismiss
    @State private var showChat = false
    @State private var showCreateStudySession = false
    @State private var showCheckInSheet = false
    @State private var selectedTab = 0
    @State private var showSuccessAlert = false
    @State private var successMessage = ""
    
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
                        ActivityHistorySection(userId: user.id)
                    } else {
                        StudyTogetherSection(userId: user.id, matchId: match.id)
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
                CreateStudySessionSheet(match: match, userId: user.id) { subject, topic in
                    successMessage = "Study session created! You'll earn 25 points when you complete it."
                    showSuccessAlert = true
                }
            }
            .sheet(isPresented: $showCheckInSheet) {
                CheckInSheet(match: match, userId: user.id) { cafeName in
                    successMessage = "Checked in at \(cafeName)! You earned 30 points ☕️"
                    showSuccessAlert = true
                }
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(successMessage)
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
                    
                    Text(user.college)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(user.city), \(user.state)")
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
            
            // Study Session Button
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
            
            // Check-In Button
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

// MARK: - Activity History Section

struct ActivityHistorySection: View {
    let userId: String
    
    var body: some View {
        VStack(spacing: 16) {
            InfoCard(title: "Recent Activity") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Check-ins, study sessions, and café visits will appear here once you start meeting up!")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("💡 Pro Tips:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ActivityTip(icon: "location.fill", text: "Check in at cafés together to earn points", color: .green)
                        ActivityTip(icon: "star.fill", text: "Unlock badges by reaching milestones", color: .yellow)
                        ActivityTip(icon: "flame.fill", text: "Build a streak by meeting regularly", color: .orange)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityTip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Study Together Section

struct StudyTogetherSection: View {
    let userId: String
    let matchId: String
    
    var body: some View {
        VStack(spacing: 16) {
            InfoCard(title: "💡 Study Date Ideas") {
                VStack(alignment: .leading, spacing: 8) {
                    StudyTip(icon: "☕️", text: "Start with coffee, review notes together")
                    StudyTip(icon: "📱", text: "Quiz each other on flashcards")
                    StudyTip(icon: "🎯", text: "Set goals and reward with treats")
                    StudyTip(icon: "⏰", text: "Use Pomodoro: 25min study, 5min chat")
                    StudyTip(icon: "🎓", text: "Teach each other your subjects")
                    StudyTip(icon: "🌟", text: "Celebrate progress with a special coffee")
                }
            }
            .padding(.horizontal)
            
            InfoCard(title: "Create Study Session") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tap the Study button above to create a study session together!")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("You'll earn 25 points for each study session you complete.")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 4)
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
        HStack(alignment: .top, spacing: 8) {
            Text(icon)
                .frame(width: 20)
            Text(text)
                .font(.caption)
        }
    }
}



// MARK: - Create Study Session Sheet

struct CreateStudySessionSheet: View {
    let match: Match
    let userId: String
    let onSuccess: (String, String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var subject = "Computer Science"
    @State private var topic = ""
    @State private var selectedDate = Date()
    @State private var duration = 60
    
    let subjects = ["Computer Science", "Mathematics", "Biology", "Chemistry", "Physics", "Engineering", "Business", "Psychology", "English", "History"]
    let durations = [30, 60, 90, 120]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Study Details") {
                    Picker("Subject", selection: $subject) {
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
                        // Save study session and notify parent
                        onSuccess(subject, topic)
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Check-In Sheet

struct CheckInSheet: View {
    let match: Match
    let userId: String
    let onSuccess: (String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var cafeName = ""
    @State private var coffeeOrdered = ""
    @State private var rating = 5
    
    var body: some View {
        NavigationView {
            Form {
                Section("Café Details") {
                    TextField("Café Name", text: $cafeName)
                    TextField("What did you order?", text: $coffeeOrdered)
                }
                
                Section("How was it?") {
                    HStack {
                        Text("Rating")
                        Spacer()
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You'll earn 30 points for this check-in! ☕️")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        Button("Check In Together") {
                            // Save check-in and notify parent
                            let finalCafeName = cafeName.isEmpty ? "this café" : cafeName
                            onSuccess(finalCafeName)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Check In at Café")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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

struct MatchEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}



#Preview {
    MatchProfileView(
        user: User(
            email: "test@test.com",
            fullName: "Sarah Johnson",
            college: "Boise State University",
            state: "Idaho",
            city: "Boise",
            favoriteCoffee: "Vanilla Latte",
            favoriteCoffeeShop: "The Human Bean",
            bio: "Coffee enthusiast and CS major. Love studying at cafés!"
        ),
        match: Match(userId1: "1", userId2: "2")
    )
}
