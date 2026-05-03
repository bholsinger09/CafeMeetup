import Foundation

/// Service for generating session recaps from live session data
/// Note: This is a mock implementation using in-memory data
@MainActor
class SessionRecapService {
    static let shared = SessionRecapService()
    
    // Mock in-memory storage for saved recaps
    private var savedRecaps: [String: SessionRecapData] = [:]
    
    private init() {}
    
    /// Generates a complete session recap from live session data
    /// - Parameters:
    ///   - studySession: The completed study session
    ///   - sessionStartTime: When the session started
    ///   - participantNames: Dictionary of participant IDs to names
    /// - Returns: SessionRecapData with all aggregated statistics
    func generateRecap(
        for studySession: StudySession,
        sessionStartTime: Date,
        participantNames: [String: String]
    ) async throws -> SessionRecapData {
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        
        // Fetch all session data from LiveSessionService
        let pomodoroStats = fetchPomodoroStats(sessionId: studySession.id)
        let whiteboardStats = fetchWhiteboardStats(sessionId: studySession.id)
        let pollResults = fetchPollResults(sessionId: studySession.id)
        let quizResults = fetchQuizResults(sessionId: studySession.id)
        
        return SessionRecapData(
            studySession: studySession,
            sessionDuration: sessionDuration,
            participantCount: studySession.attendeeIds.count,
            participantNames: Array(participantNames.values),
            pomodoroStats: pomodoroStats,
            whiteboardStats: whiteboardStats,
            topPolls: pollResults,
            quizSummary: quizResults
        )
    }
    
    // MARK: - Fetch Individual Stats
    
    private func fetchPomodoroStats(sessionId: String) -> SessionRecapData.PomodoroStats? {
        guard let pomodoroState = LiveSessionService.shared.getPomodoroState(sessionId: sessionId) else {
            return nil
        }
        
        let completedPomodoros = pomodoroState.completedPomodoros
        
        // Calculate total focus and break time based on completed pomodoros
        let totalFocusMinutes = completedPomodoros * 25
        let shortBreaks = min(completedPomodoros, 3) // First 3 get short breaks
        let longBreaks = max(0, completedPomodoros - 3) / 4 // Every 4th gets long break
        let totalBreakMinutes = (shortBreaks * 5) + (longBreaks * 15)
        
        return SessionRecapData.PomodoroStats(
            completedPomodoros: completedPomodoros,
            totalFocusMinutes: totalFocusMinutes,
            totalBreakMinutes: totalBreakMinutes,
            longestFocusStreak: completedPomodoros // Could be enhanced with actual tracking
        )
    }
    
    private func fetchWhiteboardStats(sessionId: String) -> SessionRecapData.WhiteboardStats? {
        guard let whiteboardState = LiveSessionService.shared.getWhiteboardState(sessionId: sessionId) else {
            return nil
        }
        
        let strokes = whiteboardState.strokes
        guard !strokes.isEmpty else { return nil }
        
        // Count strokes per user
        var userStrokeCounts: [String: Int] = [:]
        for stroke in strokes {
            userStrokeCounts[stroke.userId, default: 0] += 1
        }
        
        let mostActive = userStrokeCounts.max(by: { $0.value < $1.value })
        
        return SessionRecapData.WhiteboardStats(
            totalStrokes: strokes.count,
            contributingUsers: userStrokeCounts.count,
            mostActiveUser: mostActive?.key ?? "Unknown",
            mostActiveUserStrokes: mostActive?.value ?? 0,
            strokePreview: Array(strokes.prefix(10))
        )
    }
    
    private func fetchPollResults(sessionId: String) -> [SessionRecapData.PollSummary] {
        guard let poll = LiveSessionService.shared.getCurrentPoll(sessionId: sessionId) else {
            return []
        }
        
        // Find top option
        guard let topOption = poll.options.max(by: { $0.voteCount < $1.voteCount }) else {
            return []
        }
        
        let summary = SessionRecapData.PollSummary(
            id: poll.id,
            question: poll.question,
            totalVotes: poll.votes.count,
            topOption: topOption.text,
            topOptionVotes: topOption.voteCount,
            participantCount: poll.votes.count
        )
        
        return [summary]
    }
    
    private func fetchQuizResults(sessionId: String) -> SessionRecapData.QuizSummary? {
        guard let quiz = LiveSessionService.shared.getCurrentQuiz(sessionId: sessionId),
              !quiz.questions.isEmpty else {
            return nil
        }
        
        let totalQuestions = quiz.questions.count
        let scores = Array(quiz.participantScores.values)
        let averageScore = scores.isEmpty ? 0 : Double(scores.reduce(0, +)) / Double(scores.count)
        
        // Get top 3 scorers
        let sortedScores = quiz.participantScores.sorted { $0.value > $1.value }
        let topScorers = sortedScores.prefix(3).enumerated().map { index, entry in
            SessionRecapData.QuizSummary.LeaderboardEntry(
                id: entry.key,
                userId: entry.key,
                userName: "User \(entry.key.prefix(8))", // Could fetch actual names
                score: entry.value,
                rank: index + 1
            )
        }
        
        let completionRate = quiz.participantScores.isEmpty ? 0 : 100
        
        return SessionRecapData.QuizSummary(
            title: quiz.title,
            totalQuestions: totalQuestions,
            participantCount: quiz.participantScores.count,
            averageScore: averageScore,
            topScorers: topScorers,
            completionRate: completionRate
        )
    }
    
    // MARK: - Save Recap
    
    /// Saves a session recap to memory for later viewing
    func saveRecap(_ recap: SessionRecapData) async throws {
        savedRecaps[recap.id] = recap
    }
    
    /// Fetches a saved session recap
    func fetchRecap(id: String) async throws -> SessionRecapData {
        guard let recap = savedRecaps[id] else {
            throw NSError(domain: "SessionRecapService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Recap not found"])
        }
        return recap
    }
    
    /// Fetches all recaps for a user's study sessions
    func fetchRecaps(for userId: String, limit: Int = 10) async throws -> [SessionRecapData] {
        return Array(savedRecaps.values
            .filter { $0.studySession.hostId == userId }
            .sorted { $0.completedAt > $1.completedAt }
            .prefix(limit))
    }
}

// MARK: - Mock Service for Development

extension SessionRecapService {
    /// Creates a mock recap for testing/previews
    static func mockRecap(for studySession: StudySession) -> SessionRecapData {
        SessionRecapData.sample
    }
}
