import SwiftUI

/// Study Sessions Tab - PRIMARY feature of StudyBrew
/// Emphasizes group academic collaboration (3+ people)
struct StudySessionsView: View {
    @StateObject private var sessionService: StudySessionService
    @State private var showCreateSession = false
    @State private var selectedFilter: SessionFilter = .upcoming
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    enum SessionFilter: String, CaseIterable {
        case upcoming = "Upcoming"
        case my = "My Sessions"
        case byCourse = "By Course"
    }
    
    init(userId: String) {
        _sessionService = StateObject(wrappedValue: StudySessionService(userId: userId))
    }
    
    var body: some View {
        content
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
    
    private var content: some View {
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
                    if horizontalSizeClass == .regular {
                        // iPad: 3-column grid layout optimized for iPad Air 11"
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            // Info banner
                            infoBanner
                                .gridCellColumns(3)
                            
                            // Sessions based on filter
                            ForEach(filteredSessions) { session in
                                SessionCard(
                                    session: session,
                                    currentUserId: sessionService.currentUserId,
                                    onJoin: {
                                        sessionService.joinSession(session, userName: "Current User")
                                    },
                                    onLeave: {
                                        sessionService.leaveSession(session)
                                    },
                                    isCompact: true
                                )
                            }
                            
                            if filteredSessions.isEmpty {
                                emptyStateView
                                    .gridCellColumns(3)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    } else {
                        // iPhone: Vertical list
                        LazyVStack(spacing: 16) {
                            // Info banner
                            infoBanner
                            
                            // Sessions based on filter
                            ForEach(filteredSessions) { session in
                                SessionCard(
                                    session: session,
                                    currentUserId: sessionService.currentUserId,
                                    onJoin: {
                                        sessionService.joinSession(session, userName: "Current User")
                                    },
                                    onLeave: {
                                        sessionService.leaveSession(session)
                                    },
                                    isCompact: true
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
    let currentUserId: String
    let onJoin: () -> Void
    let onLeave: () -> Void
    var isCompact: Bool = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var hasJoined: Bool {
        session.attendeeIds.contains(currentUserId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
            // Course header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.courseCode)
                        .font(isCompact ? .subheadline : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                    
                    Text(session.courseName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Group size indicator
                GroupSizeIndicator(current: session.attendeeIds.count, max: session.maxAttendees, isCompact: true)
            }
            
            // Study topic
            Text(session.studyTopic)
                .font(isCompact ? .caption : .body)
                .fontWeight(.medium)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            // Session details
            VStack(alignment: .leading, spacing: 4) {
                SessionDetailRow(icon: "calendar", text: formatDate(session.scheduledDate), isCompact: true)
                SessionDetailRow(icon: "clock", text: "\(session.duration) min", isCompact: true)
                SessionDetailRow(icon: "location.fill", text: session.cafeName, isCompact: true)
                SessionDetailRow(icon: "person.3.fill", text: session.hostName, isCompact: true)
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            
            // Attendees preview - compact
            if !session.attendeeIds.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Attendees (\(session.attendeeIds.count))")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(Array(session.attendeeNames.values.prefix(2)), id: \.self) { name in
                                Text(name)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.brown.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            if session.attendeeNames.count > 2 {
                                Text("+\(session.attendeeNames.count - 2)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Join/Leave button
            Button(action: { 
                if hasJoined {
                    onLeave()
                } else {
                    onJoin()
                }
            }) {
                HStack(spacing: 4) {
                    if session.isFull {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                    } else if hasJoined {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                    } else {
                        Image(systemName: "person.badge.plus")
                            .font(.caption)
                    }
                    
                    if session.isFull {
                        Text("Full")
                            .font(.caption)
                    } else if hasJoined {
                        Text("Joined")
                            .font(.caption)
                    } else {
                        Text("Join Session")
                            .font(.caption)
                    }
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(session.isFull ? Color.gray : (hasJoined ? Color.green : Color.brown))
                .cornerRadius(8)
            }
            .disabled(session.isFull)
            
            // Enter Live Session button (only shows when joined)
            if hasJoined {
                NavigationLink(destination: 
                    LiveStudySessionView(
                        studySession: session,
                        userId: currentUserId,
                        userName: "Current User",
                        isHost: session.hostId == currentUserId
                    )
                ) {
                    HStack(spacing: 4) {
                        Image(systemName: "live.photo")
                            .font(.caption)
                        Text("Enter Live Session")
                            .font(.caption)
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
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
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: isCompact ? 3 : 4) {
            Image(systemName: "person.3.fill")
                .font(isCompact ? .caption2 : .caption)
            Text("\(current)/\(max)")
                .font(isCompact ? .caption2 : .caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 5 : 6)
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
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: isCompact ? 6 : 8) {
            Image(systemName: icon)
                .frame(width: isCompact ? 16 : 20)
                .font(isCompact ? .caption : .body)
            Text(text)
                .lineLimit(1)
        }
    }
}

#Preview {
    StudySessionsView(userId: "preview-user")
}
