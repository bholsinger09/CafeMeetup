import SwiftUI

/// Live Study Session View - Hub for all real-time collaboration features
struct LiveStudySessionView: View {
    let studySession: StudySession
    let userId: String
    let userName: String
    let isHost: Bool
    
    @State private var activeParticipants: [String] = []
    @State private var showWhiteboard = false
    @State private var showPomodoro = false
    @State private var showPoll = false
    @State private var showQuiz = false
    @State private var isSessionActive = false
    @State private var showQRCode = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Session header
                    sessionHeaderView
                    
                    // Active participants
                    activeParticipantsView
                    
                    // Feature grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        featureCard(
                            title: "Whiteboard",
                            icon: "scribble",
                            color: .blue,
                            description: "Collaborate on diagrams"
                        ) {
                            showWhiteboard = true
                        }
                        
                        featureCard(
                            title: "Pomodoro",
                            icon: "timer",
                            color: .red,
                            description: "Focus together"
                        ) {
                            showPomodoro = true
                        }
                        
                        featureCard(
                            title: "Poll",
                            icon: "chart.bar.fill",
                            color: .green,
                            description: "Quick votes"
                        ) {
                            showPoll = true
                        }
                        
                        featureCard(
                            title: "Quiz",
                            icon: "questionmark.circle.fill",
                            color: .orange,
                            description: "Test knowledge"
                        ) {
                            showQuiz = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Session info
                    sessionInfoView
                    
                    // Session controls
                    if isHost {
                        sessionControlsView
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Live Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isHost {
                    Button(action: { showQRCode = true }) {
                        Image(systemName: "qrcode")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: leaveSession) {
                    Text("Leave")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showWhiteboard) {
            CollaborativeWhiteboardView(
                viewModel: WhiteboardViewModel(
                    studySessionId: studySession.id,
                    userId: userId,
                    userName: userName
                )
            )
        }
        .sheet(isPresented: $showPomodoro) {
            SyncedPomodoroTimerView(
                viewModel: PomodoroViewModel(
                    studySessionId: studySession.id,
                    isHost: isHost
                )
            )
        }
        .sheet(isPresented: $showPoll) {
            LivePollView(
                viewModel: LivePollViewModel(
                    studySessionId: studySession.id,
                    userId: userId,
                    userName: userName,
                    isHost: isHost
                )
            )
        }
        .sheet(isPresented: $showQuiz) {
            LiveQuizView(
                viewModel: LiveQuizViewModel(
                    studySessionId: studySession.id,
                    userId: userId,
                    userName: userName,
                    isHost: isHost
                )
            )
        }
        .sheet(isPresented: $showQRCode) {
            QRCodeGeneratorView(
                studySession: studySession,
                userId: userId
            )
        }
        .onAppear {
            joinLiveSession()
        }
        .onDisappear {
            leaveLiveSession()
        }
    }
    
    private var sessionHeaderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text(studySession.courseName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(studySession.studyTopic)
                .font(.headline)
                .foregroundColor(Color.black.opacity(0.6))
            
            if isSessionActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Live Now")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .padding(.horizontal)
        .colorScheme(.light)
    }
    
    private var activeParticipantsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                
                Text("Active Now (\(activeParticipants.count))")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(activeParticipants, id: \.self) { participant in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.blue.opacity(0.8))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(participant.prefix(1).uppercased())
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            Text(participant)
                                .font(.caption2)
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                        .frame(width: 70)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .padding(.horizontal)
        .colorScheme(.light)
    }
    
    private func featureCard(title: String, icon: String, color: Color, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.black.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            .colorScheme(.light)
        }
    }
    
    private var sessionInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Details")
                .font(.headline)
                .foregroundColor(.black)
            
            InfoRow(icon: "building.2.fill", label: "Location", value: studySession.cafeName)
            InfoRow(icon: "calendar", label: "Date", value: studySession.scheduledDate.formatted(date: .abbreviated, time: .shortened))
            InfoRow(icon: "clock.fill", label: "Duration", value: "\(studySession.duration) minutes")
            InfoRow(icon: "person.fill", label: "Host", value: studySession.hostName)
            
            if let materials = studySession.studyMaterials, !materials.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.blue)
                        Text("Materials:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    
                    ForEach(materials, id: \.self) { material in
                        Text("• \(material)")
                            .font(.caption)
                            .foregroundColor(Color.black.opacity(0.6))
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .padding(.horizontal)
        .colorScheme(.light)
    }
    
    private var sessionControlsView: some View {
        VStack(spacing: 12) {
            Text("Host Controls")
                .font(.headline)
                .foregroundColor(.black)
            
            if isSessionActive {
                Button(action: endSession) {
                    Label("End Session", systemImage: "stop.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
            } else {
                Button(action: startSession) {
                    Label("Start Session", systemImage: "play.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .padding(.horizontal)
        .colorScheme(.light)
    }
    
    // MARK: - Actions
    
    private func joinLiveSession() {
        LiveSessionService.shared.joinLiveSession(
            studySessionId: studySession.id,
            userId: userId,
            userName: userName
        )
        
        // Observe active participants
        LiveSessionService.shared.observeActiveParticipants(sessionId: studySession.id) { participants in
            Task { @MainActor in
                activeParticipants = participants
            }
        }
        
        isSessionActive = studySession.status == .active
    }
    
    private func leaveLiveSession() {
        LiveSessionService.shared.leaveLiveSession(studySessionId: studySession.id, userId: userId)
    }
    
    private func startSession() {
        isSessionActive = true
        // Update session status in database
    }
    
    private func endSession() {
        isSessionActive = false
        // Update session status in database
        dismiss()
    }
    
    private func leaveSession() {
        leaveLiveSession()
        dismiss()
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label + ":")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .foregroundColor(Color.black.opacity(0.6))
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        LiveStudySessionView(
            studySession: StudySession(
                hostId: "user1",
                hostName: "John Doe",
                courseCode: "CS 101",
                courseName: "Introduction to Programming",
                studyTopic: "Midterm Review",
                cafeId: "cafe1",
                cafeName: "Starbucks Downtown",
                scheduledDate: Date(),
                status: .active
            ),
            userId: "user2",
            userName: "Jane Smith",
            isHost: false
        )
    }
}
