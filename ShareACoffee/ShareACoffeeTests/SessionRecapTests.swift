import XCTest
@testable import ShareACoffee

/// Tests for Session Recap functionality
@MainActor
final class SessionRecapTests: XCTestCase {
    
    var recapService: SessionRecapService!
    var mockSession: StudySession!
    
    override func setUp() async throws {
        recapService = SessionRecapService.shared
        
        // Create mock study session
        mockSession = StudySession(
            id: "test-session",
            hostId: "user1",
            hostName: "Test Host",
            courseCode: "CS 101",
            courseName: "Introduction to Programming",
            studyTopic: "Test Topic",
            cafeId: "cafe1",
            cafeName: "Test Cafe",
            scheduledDate: Date(),
            duration: 120,
            attendeeIds: ["user1", "user2", "user3"],
            attendeeNames: ["user1": "Alice", "user2": "Bob", "user3": "Charlie"],
            status: .completed
        )
    }
    
    // MARK: - Recap Generation Tests
    
    func testGenerateRecapWithNoData() async throws {
        // When: Generate recap with no session data
        let recap = try await recapService.generateRecap(
            for: mockSession,
            sessionStartTime: Date().addingTimeInterval(-7200), // 2 hours ago
            participantNames: mockSession.attendeeNames
        )
        
        // Then: Recap should be created with basic info
        XCTAssertEqual(recap.studySession.id, mockSession.id)
        XCTAssertEqual(recap.participantCount, 3)
        XCTAssertNil(recap.pomodoroStats)
        XCTAssertNil(recap.whiteboardStats)
        XCTAssertTrue(recap.topPolls.isEmpty)
        XCTAssertNil(recap.quizSummary)
    }
    
    func testGenerateRecapWithPomodoroStats() async throws {
        // Given: Session has Pomodoro data
        let pomodoroState = PomodoroState(
            completedPomodoros: 4,
            totalFocusMinutes: 100
        )
        LiveSessionService.shared.updatePomodoroState(
            sessionId: mockSession.id,
            state: pomodoroState
        ) { _ in }
        
        // When: Generate recap
        let recap = try await recapService.generateRecap(
            for: mockSession,
            sessionStartTime: Date().addingTimeInterval(-7200),
            participantNames: mockSession.attendeeNames
        )
        
        // Then: Pomodoro stats should be included
        XCTAssertNotNil(recap.pomodoroStats)
        XCTAssertEqual(recap.pomodoroStats?.completedPomodoros, 4)
        XCTAssertEqual(recap.pomodoroStats?.totalFocusMinutes, 100)
    }
    
    func testGenerateRecapWithWhiteboardStats() async throws {
        // Given: Session has whiteboard strokes
        let strokes = [
            WhiteboardStroke(userId: "user1", userName: "Alice"),
            WhiteboardStroke(userId: "user1", userName: "Alice"),
            WhiteboardStroke(userId: "user2", userName: "Bob")
        ]
        let whiteboardState = WhiteboardState(strokes: strokes)
        LiveSessionService.shared.updateWhiteboardState(
            sessionId: mockSession.id,
            state: whiteboardState
        ) { _ in }
        
        // When: Generate recap
        let recap = try await recapService.generateRecap(
            for: mockSession,
            sessionStartTime: Date().addingTimeInterval(-7200),
            participantNames: mockSession.attendeeNames
        )
        
        // Then: Whiteboard stats should be included
        XCTAssertNotNil(recap.whiteboardStats)
        XCTAssertEqual(recap.whiteboardStats?.totalStrokes, 3)
        XCTAssertEqual(recap.whiteboardStats?.contributingUsers, 2)
        XCTAssertEqual(recap.whiteboardStats?.mostActiveUser, "user1")
    }
    
    func testGenerateRecapWithPollResults() async throws {
        // Given: Session has a poll
        let poll = LivePoll(
            studySessionId: mockSession.id,
            createdBy: "user1",
            createdByName: "Alice",
            question: "Test Question?",
            options: [
                LivePoll.PollOption(text: "Option A", voteCount: 5),
                LivePoll.PollOption(text: "Option B", voteCount: 2)
            ],
            votes: ["user1": 0, "user2": 0, "user3": 0],
            isActive: false
        )
        LiveSessionService.shared.createPoll(
            sessionId: mockSession.id,
            poll: poll
        ) { _ in }
        
        // When: Generate recap
        let recap = try await recapService.generateRecap(
            for: mockSession,
            sessionStartTime: Date().addingTimeInterval(-7200),
            participantNames: mockSession.attendeeNames
        )
        
        // Then: Poll results should be included
        XCTAssertFalse(recap.topPolls.isEmpty)
        XCTAssertEqual(recap.topPolls.first?.question, "Test Question?")
        XCTAssertEqual(recap.topPolls.first?.topOption, "Option A")
    }
    
    func testGenerateRecapWithQuizResults() async throws {
        // Given: Session has a quiz
        let quiz = LiveQuiz(
            studySessionId: mockSession.id,
            createdBy: "user1",
            createdByName: "Alice",
            title: "Test Quiz",
            questions: [
                .init(question: "Q1", options: ["A", "B"], correctAnswerIndex: 0),
                .init(question: "Q2", options: ["A", "B"], correctAnswerIndex: 1)
            ],
            participantScores: ["user1": 2, "user2": 1, "user3": 1],
            isActive: false
        )
        LiveSessionService.shared.createQuiz(
            sessionId: mockSession.id,
            quiz: quiz
        ) { _ in }
        
        // When: Generate recap
        let recap = try await recapService.generateRecap(
            for: mockSession,
            sessionStartTime: Date().addingTimeInterval(-7200),
            participantNames: mockSession.attendeeNames
        )
        
        // Then: Quiz results should be included
        XCTAssertNotNil(recap.quizSummary)
        XCTAssertEqual(recap.quizSummary?.title, "Test Quiz")
        XCTAssertEqual(recap.quizSummary?.totalQuestions, 2)
        XCTAssertEqual(recap.quizSummary?.participantCount, 3)
    }
    
    // MARK: - Save/Fetch Tests
    
    func testSaveAndFetchRecap() async throws {
        // Given: A recap
        let recap = try await recapService.generateRecap(
            for: mockSession,
            sessionStartTime: Date().addingTimeInterval(-7200),
            participantNames: mockSession.attendeeNames
        )
        
        // When: Save recap
        try await recapService.saveRecap(recap)
        
        // Then: Should be able to fetch it back
        let fetchedRecap = try await recapService.fetchRecap(id: recap.id)
        XCTAssertEqual(fetchedRecap.id, recap.id)
        XCTAssertEqual(fetchedRecap.studySession.id, mockSession.id)
    }
    
    func testFetchRecapsForUser() async throws {
        // Given: Multiple recaps for a user
        let recap1 = try await recapService.generateRecap(
            for: mockSession,
            sessionStartTime: Date().addingTimeInterval(-7200),
            participantNames: mockSession.attendeeNames
        )
        try await recapService.saveRecap(recap1)
        
        var session2 = mockSession!
        session2.id = "test-session-2"
        let recap2 = try await recapService.generateRecap(
            for: session2,
            sessionStartTime: Date().addingTimeInterval(-3600),
            participantNames: session2.attendeeNames
        )
        try await recapService.saveRecap(recap2)
        
        // When: Fetch recaps for user
        let recaps = try await recapService.fetchRecaps(for: "user1")
        
        // Then: Should return both recaps, most recent first
        XCTAssertEqual(recaps.count, 2)
    }
    
    // MARK: - Mock Data Test
    
    func testMockRecapData() {
        // When: Get mock recap
        let mockRecap = SessionRecapService.mockRecap(for: mockSession)
        
        // Then: Should have sample data
        XCTAssertEqual(mockRecap.studySession.id, mockSession.id)
        XCTAssertTrue(mockRecap.hasAnyData)
        XCTAssertGreaterThan(mockRecap.highlightCount, 0)
    }
    
    // MARK: - SessionRecapData Tests
    
    func testSessionDurationFormatting() {
        let recap = SessionRecapData(
            studySession: mockSession,
            sessionDuration: 7200, // 2 hours
            participantCount: 3,
            participantNames: ["Alice", "Bob", "Charlie"]
        )
        
        XCTAssertEqual(recap.sessionDurationFormatted, "2h 0m")
    }
    
    func testPomodoroStatsFocusTime() {
        let stats = SessionRecapData.PomodoroStats(
            completedPomodoros: 4,
            totalFocusMinutes: 100,
            totalBreakMinutes: 20,
            longestFocusStreak: 2
        )
        
        XCTAssertEqual(stats.totalFocusTime, "1h 40m")
    }
    
    func testQuizLeaderboardMedals() {
        let entry1 = SessionRecapData.QuizSummary.LeaderboardEntry(
            id: "1",
            userId: "u1",
            userName: "Alice",
            score: 10,
            rank: 1
        )
        let entry2 = SessionRecapData.QuizSummary.LeaderboardEntry(
            id: "2",
            userId: "u2",
            userName: "Bob",
            score: 9,
            rank: 2
        )
        let entry3 = SessionRecapData.QuizSummary.LeaderboardEntry(
            id: "3",
            userId: "u3",
            userName: "Charlie",
            score: 8,
            rank: 3
        )
        
        XCTAssertEqual(entry1.medalEmoji, "🥇")
        XCTAssertEqual(entry2.medalEmoji, "🥈")
        XCTAssertEqual(entry3.medalEmoji, "🥉")
    }
}
