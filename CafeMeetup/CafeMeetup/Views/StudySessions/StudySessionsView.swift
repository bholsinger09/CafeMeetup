import SwiftUI

/// Study Sessions Tab - PRIMARY feature of LatteLink
/// Emphasizes group academic collaboration (3+ people)
struct StudySessionsView: View {
    @StateObject private var sessionService: StudySessionService
    @State private var showCreateSession = false
    @State private var selectedFilter: SessionFilter = .upcoming
    
    enum SessionFilter: String, CaseIterable {
        case upcoming = "Upcoming"
        case my = "My Sessions"
        case byCourse = "By Course"
    }
    
    init(userId: String) {
        _sessionService = StateObject(wrappedValue: StudySessionService(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(SessionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Sessions List
                if sessionService.isLoading {
                    ProgressView("Loading study sessions...")
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Info banner
                            infoBanner
                            
                            // Sessions based on filter
                            ForEach(filteredSessions) { session in
                                SessionCard(
                                    session: session,
                                    onJoin: {
                                        sessionService.joinSession(session, userName: "Current User")
                                    },
                                    onLeave: {
                                        sessionService.leaveSession(session)
                                    }
                                )
                            }
                            
                            if filteredSessions.isEmpty {
                                emptyStateView
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Study Sessions")
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateSession = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $showCreateSession) {
                CreateStudySessionView(sessionService: sessionService)
            }
        }
    }
    
    private var infoBanner: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
            Text("Join group study sessions (3+ people) to collaborate on coursework")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Study Sessions Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(emptyStateMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showCreateSession = true }) {
                Label("Create Study Session", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .upcoming:
            return "No upcoming study sessions available. Create one to get started!"
        case .my:
            return "You haven't joined any study sessions yet. Browse upcoming sessions or create your own!"
        case .byCourse:
            return "Add courses to your profile to see study sessions for your classes."
        }
    }
    
    private var filteredSessions: [StudySession] {
        switch selectedFilter {
        case .upcoming:
            return sessionService.publicSessions.filter { $0.isUpcoming && $0.status == .scheduled }
        case .my:
            return sessionService.mySessions.filter { $0.isUpcoming && $0.status == .scheduled }
        case .byCourse:
            return sessionService.publicSessions.filter { $0.isUpcoming && $0.status == .scheduled }
        }
    }
}

// MARK: - Study Session Card

struct SessionCard: View {
    let session: StudySession
    let onJoin: () -> Void
    let onLeave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Course header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.courseCode)
                        .font(.headline)
                        .foregroundColor(.brown)
                    
                    Text(session.courseName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Group size indicator
                GroupSizeIndicator(current: session.attendeeIds.count, max: session.maxAttendees)
            }
            
            // Study topic
            Text(session.studyTopic)
                .font(.body)
                .fontWeight(.medium)
            
            Divider()
            
            // Session details
            VStack(alignment: .leading, spacing: 8) {
                SessionDetailRow(icon: "calendar", text: formatDate(session.scheduledDate))
                SessionDetailRow(icon: "clock", text: "\(session.duration) minutes")
                SessionDetailRow(icon: "location.fill", text: session.cafeName)
                SessionDetailRow(icon: "person.3.fill", text: "Hosted by \(session.hostName)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            // Attendees preview
            if !session.attendeeIds.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Attendees (\(session.attendeeIds.count))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(session.attendeeNames.values), id: \.self) { name in
                                Text(name)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.brown.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            // Join/Leave button
            Button(action: { /* Check if already joined */ onJoin() }) {
                HStack {
                    Image(systemName: session.isFull ? "lock.fill" : "person.badge.plus")
                    Text(session.isFull ? "Session Full" : "Join Session")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(session.isFull ? Color.gray : Color.brown)
                .cornerRadius(12)
            }
            .disabled(session.isFull)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct GroupSizeIndicator: View {
    let current: Int
    let max: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.3.fill")
                .font(.caption)
            Text("\(current)/\(max)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(fillColor)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    private var fillColor: Color {
        let ratio = Double(current) / Double(max)
        if ratio >= 0.8 { return .red }
        if ratio >= 0.5 { return .orange }
        return .green
    }
}

struct SessionDetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 20)
            Text(text)
        }
    }
}

#Preview {
    StudySessionsView(userId: "preview-user")
}
