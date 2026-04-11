import SwiftUI
import Combine

/// Synchronized Pomodoro Timer - Shared focus timer for study groups
struct SyncedPomodoroTimerView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background based on phase
                LinearGradient(
                    colors: [
                        viewModel.pomodoroState.currentPhase.color.opacity(0.3),
                        viewModel.pomodoroState.currentPhase.color.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Phase indicator
                    phaseIndicatorView
                    
                    // Main timer display
                    timerDisplayView
                    
                    // Progress ring
                    progressRingView
                    
                    // Controls
                    controlButtonsView
                    
                    // Stats
                    statsView
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Focus Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.resetTimer() }) {
                            Label("Reset Timer", systemImage: "arrow.counterclockwise")
                        }
                        
                        Button(action: { viewModel.skipPhase() }) {
                            Label("Skip Phase", systemImage: "forward.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    private var phaseIndicatorView: some View {
        VStack(spacing: 8) {
            Text(viewModel.pomodoroState.currentPhase.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(viewModel.pomodoroState.currentPhase.color)
            
            HStack(spacing: 4) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index < viewModel.pomodoroState.completedPomodoros ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            
            Text("\(viewModel.pomodoroState.completedPomodoros) Pomodoros Completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    private var timerDisplayView: some View {
        VStack(spacing: 8) {
            Text(timeString(from: viewModel.pomodoroState.secondsRemaining))
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)
            
            if viewModel.isHost {
                Text("You control the timer")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Synced with group")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var progressRingView: some View {
        let progress = Double(viewModel.pomodoroState.secondsRemaining) / Double(viewModel.pomodoroState.currentPhase.duration)
        
        return ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    viewModel.pomodoroState.currentPhase.color,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
    }
    
    private var controlButtonsView: some View {
        HStack(spacing: 30) {
            // Only host can control the timer
            if viewModel.isHost {
                if viewModel.pomodoroState.isRunning {
                    Button(action: { viewModel.pauseTimer() }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                    }
                } else {
                    Button(action: { viewModel.startTimer() }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                }
                
                Button(action: { viewModel.skipPhase() }) {
                    Image(systemName: "forward.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: viewModel.pomodoroState.isRunning ? "timer" : "pause.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Waiting for host...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var statsView: some View {
        HStack(spacing: 40) {
            StatItem(
                icon: "person.2.fill",
                value: "\(viewModel.activeParticipants.count)",
                label: "Studying"
            )
            
            StatItem(
                icon: "clock.fill",
                value: "\(viewModel.totalMinutesStudied)",
                label: "Minutes"
            )
            
            StatItem(
                icon: "flame.fill",
                value: "\(viewModel.pomodoroState.completedPomodoros)",
                label: "Pomodoros"
            )
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Stat Item Component

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - ViewModel

class PomodoroViewModel: ObservableObject {
    @Published var pomodoroState: PomodoroState
    @Published var activeParticipants: [String] = []
    @Published var totalMinutesStudied: Int = 0
    
    let studySessionId: String
    let isHost: Bool
    
    private let liveSessionService = LiveSessionService.shared
    private var timerSubscription: Timer?
    
    init(studySessionId: String, isHost: Bool, existingState: PomodoroState? = nil) {
        self.studySessionId = studySessionId
        self.isHost = isHost
        self.pomodoroState = existingState ?? PomodoroState()
        
        setupRealtimeListeners()
        
        if pomodoroState.isRunning {
            startLocalTimer()
        }
    }
    
    deinit {
        timerSubscription?.invalidate()
    }
    
    func setupRealtimeListeners() {
        // Listen for timer state changes from Firebase
        liveSessionService.observePomodoroState(sessionId: studySessionId) { [weak self] state in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // If timer state changed, update UI
                if state.isRunning != self.pomodoroState.isRunning {
                    if state.isRunning {
                        self.startLocalTimer()
                    } else {
                        self.stopLocalTimer()
                    }
                }
                
                self.pomodoroState = state
            }
        }
        
        // Listen for active participants
        liveSessionService.observeActiveParticipants(sessionId: studySessionId) { [weak self] participants in
            DispatchQueue.main.async {
                self?.activeParticipants = participants
            }
        }
    }
    
    func startTimer() {
        guard isHost else { return }
        
        pomodoroState.isRunning = true
        pomodoroState.startedAt = Date()
        pomodoroState.pausedAt = nil
        
        syncToFirebase()
        startLocalTimer()
    }
    
    func pauseTimer() {
        guard isHost else { return }
        
        pomodoroState.isRunning = false
        pomodoroState.pausedAt = Date()
        
        syncToFirebase()
        stopLocalTimer()
    }
    
    func resetTimer() {
        guard isHost else { return }
        
        pomodoroState = PomodoroState()
        syncToFirebase()
        stopLocalTimer()
    }
    
    func skipPhase() {
        guard isHost else { return }
        
        // Advance to next phase
        switch pomodoroState.currentPhase {
        case .work:
            pomodoroState.completedPomodoros += 1
            if pomodoroState.completedPomodoros % 4 == 0 {
                pomodoroState.currentPhase = .longBreak
            } else {
                pomodoroState.currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            pomodoroState.currentPhase = .work
        }
        
        pomodoroState.secondsRemaining = pomodoroState.currentPhase.duration
        pomodoroState.startedAt = Date()
        
        syncToFirebase()
    }
    
    private func startLocalTimer() {
        stopLocalTimer()
        
        timerSubscription = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.pomodoroState.secondsRemaining > 0 {
                self.pomodoroState.secondsRemaining -= 1
                
                if self.pomodoroState.currentPhase == .work {
                    self.totalMinutesStudied += 1
                }
                
                // Sync every 10 seconds if host
                if self.isHost && self.pomodoroState.secondsRemaining % 10 == 0 {
                    self.syncToFirebase()
                }
            } else {
                // Phase completed
                self.handlePhaseCompletion()
            }
        }
    }
    
    private func stopLocalTimer() {
        timerSubscription?.invalidate()
        timerSubscription = nil
    }
    
    private func handlePhaseCompletion() {
        guard isHost else { return }
        
        // Auto-advance to next phase
        skipPhase()
        
        // Play sound or send notification
        playCompletionSound()
    }
    
    private func playCompletionSound() {
        // TODO: Add haptic feedback and sound
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func syncToFirebase() {
        liveSessionService.updatePomodoroState(sessionId: studySessionId, state: pomodoroState) { success in
            print("Pomodoro state synced: \(success)")
        }
    }
}

#Preview {
    SyncedPomodoroTimerView(
        viewModel: PomodoroViewModel(
            studySessionId: "session123",
            isHost: true
        )
    )
}
