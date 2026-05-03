import SwiftUI
import Charts

/// Individual highlight cards for different session features
/// These are designed to be screenshot-ready and shareable on social media

// MARK: - Pomodoro Stats Card

struct PomodoroStatsCard: View {
    let stats: SessionRecapData.PomodoroStats
    let sessionInfo: String
    let participantCount: Int
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.red.opacity(0.8), Color.orange.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "timer.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Focus Session Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(sessionInfo)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Stats Grid
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        statBox(
                            value: "\(stats.completedPomodoros)",
                            label: "Pomodoros",
                            icon: "flame.fill",
                            color: .white
                        )
                        
                        statBox(
                            value: stats.totalFocusTime,
                            label: "Focus Time",
                            icon: "clock.fill",
                            color: .white
                        )
                    }
                    
                    HStack(spacing: 20) {
                        statBox(
                            value: "\(stats.totalBreakMinutes)m",
                            label: "Break Time",
                            icon: "cup.and.saucer.fill",
                            color: .white
                        )
                        
                        statBox(
                            value: "\(participantCount)",
                            label: "Students",
                            icon: "person.3.fill",
                            color: .white
                        )
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
                // Footer
                Text("StudyBrew • Focused Learning")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1080)
    }
    
    private func statBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(color.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Quiz Results Card

struct QuizResultsCard: View {
    let summary: SessionRecapData.QuizSummary
    let sessionInfo: String
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text(summary.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(sessionInfo)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Top 3 Leaderboard
                VStack(spacing: 12) {
                    Text("Top Scorers")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(summary.topScorers.prefix(3)) { entry in
                        HStack {
                            Text(entry.medalEmoji)
                                .font(.title2)
                            
                            Text(entry.userName)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(entry.score)/\(summary.totalQuestions)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(entry.rank == 1 ? 0.3 : 0.2))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                
                // Stats
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(summary.participantCount)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Participants")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Divider()
                        .background(Color.white)
                        .frame(height: 50)
                    
                    VStack(spacing: 4) {
                        Text("\(summary.averageScorePercentage)%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Avg Score")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
                // Footer
                Text("StudyBrew • Learn Together")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1080)
    }
}

// MARK: - Poll Results Card

struct PollResultsCard: View {
    let poll: SessionRecapData.PollSummary
    let sessionInfo: String
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.green.opacity(0.8), Color.mint.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Group Decision")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(sessionInfo)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Question
                VStack(spacing: 16) {
                    Text(poll.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    
                    // Winner
                    VStack(spacing: 8) {
                        Text("Most Popular")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(poll.topOption)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("\(poll.topOptionPercentage)% voted for this")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(16)
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                
                // Stats
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(poll.totalVotes)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Total Votes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Divider()
                        .background(Color.white)
                        .frame(height: 50)
                    
                    VStack(spacing: 4) {
                        Text("\(poll.participantCount)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Students")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
                // Footer
                Text("StudyBrew • Vote Together")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1080)
    }
}

// MARK: - Whiteboard Stats Card

struct WhiteboardStatsCard: View {
    let stats: SessionRecapData.WhiteboardStats
    let sessionInfo: String
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "scribble.variable")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Collaboration Board")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(sessionInfo)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Stats
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        statBox(
                            value: "\(stats.totalStrokes)",
                            label: "Ideas Drawn",
                            icon: "pencil.tip",
                            color: .white
                        )
                        
                        statBox(
                            value: "\(stats.contributingUsers)",
                            label: "Contributors",
                            icon: "person.2.fill",
                            color: .white
                        )
                    }
                    
                    // MVP
                    VStack(spacing: 8) {
                        Text("Most Active")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            
                            Text(stats.mostActiveUser)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Text("\(stats.mostActiveUserStrokes) strokes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                
                Spacer()
                
                // Footer
                Text("StudyBrew • Draw Ideas Together")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1080)
    }
    
    private func statBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(color.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Session Summary Card

struct SessionSummaryCard: View {
    let recapData: SessionRecapData
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.indigo.opacity(0.9), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                    
                    Text("Session Complete!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(recapData.studySession.courseName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                    
                    Text(recapData.studySession.studyTopic)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                
                // Main Stats
                HStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text(recapData.sessionDurationFormatted)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Session Time")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Divider()
                        .background(Color.white)
                        .frame(height: 60)
                    
                    VStack(spacing: 8) {
                        Text("\(recapData.participantCount)")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Students")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
                // Highlights Summary
                VStack(spacing: 12) {
                    Text("Session Highlights")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        if recapData.pomodoroStats != nil {
                            highlightBadge(icon: "timer", label: "Pomodoro", color: .red)
                        }
                        
                        if recapData.whiteboardStats?.hasContent == true {
                            highlightBadge(icon: "scribble", label: "Whiteboard", color: .blue)
                        }
                        
                        if recapData.quizSummary != nil {
                            highlightBadge(icon: "brain", label: "Quiz", color: .orange)
                        }
                        
                        if !recapData.topPolls.isEmpty {
                            highlightBadge(icon: "chart.bar", label: "Poll", color: .green)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                
                Spacer()
                
                // Footer
                VStack(spacing: 4) {
                    Text("StudyBrew")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Where Students Study Together")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1080)
    }
    
    private func highlightBadge(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon + ".fill")
                .font(.title2)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(width: 70, height: 70)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Previews

#Preview("Pomodoro Card") {
    PomodoroStatsCard(
        stats: SessionRecapData.PomodoroStats(
            completedPomodoros: 4,
            totalFocusMinutes: 100,
            totalBreakMinutes: 20,
            longestFocusStreak: 2
        ),
        sessionInfo: "CS 101: Recursion",
        participantCount: 5
    )
}

#Preview("Quiz Card") {
    QuizResultsCard(
        summary: SessionRecapData.sample.quizSummary!,
        sessionInfo: "CS 101: Data Structures"
    )
}

#Preview("Poll Card") {
    PollResultsCard(
        poll: SessionRecapData.sample.topPolls[0],
        sessionInfo: "CS 101: Algorithms"
    )
}

#Preview("Whiteboard Card") {
    WhiteboardStatsCard(
        stats: SessionRecapData.sample.whiteboardStats!,
        sessionInfo: "CS 101: System Design"
    )
}

#Preview("Summary Card") {
    SessionSummaryCard(recapData: SessionRecapData.sample)
}
