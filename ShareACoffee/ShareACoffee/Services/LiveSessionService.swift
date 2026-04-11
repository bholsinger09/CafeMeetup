import Foundation
import Combine

/// Service for managing real-time collaborative features during live study sessions
/// Note: This is a mock implementation. For production, integrate with Firebase Realtime Database.
class LiveSessionService {
    static let shared = LiveSessionService()
    
    // Mock in-memory storage
    private var liveSessions: [String: LiveSession] = [:]
    private var whiteboardStates: [String: WhiteboardState] = [:]
    private var pomodoroStates: [String: PomodoroState] = [:]
    private var currentPolls: [String: LivePoll] = [:]
    private var currentQuizzes: [String: LiveQuiz] = [:]
    private var activeParticipants: [String: Set<String>] = [:]
    
    // Publishers for real-time updates
    private var whiteboardSubjects: [String: PassthroughSubject<WhiteboardState, Never>] = [:]
    private var pomodoroSubjects: [String: PassthroughSubject<PomodoroState, Never>] = [:]
    private var participantsSubjects: [String: PassthroughSubject<[String], Never>] = [:]
    private var pollSubjects: [String: PassthroughSubject<LivePoll?, Never>] = [:]
    private var quizSubjects: [String: PassthroughSubject<LiveQuiz?, Never>] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Live Session Management
    
    /// Start a live session for a study session
    func startLiveSession(studySessionId: String, userId: String, completion: @escaping (Bool) -> Void) {
        let liveSession = LiveSession(studySessionId: studySessionId)
        liveSessions[studySessionId] = liveSession
        
        // Initialize empty states
        whiteboardStates[studySessionId] = WhiteboardState()
        pomodoroStates[studySessionId] = PomodoroState()
        activeParticipants[studySessionId] = []
        
        // Add user as participant
        joinLiveSession(studySessionId: studySessionId, userId: userId, userName: "")
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Join an active live session
    func joinLiveSession(studySessionId: String, userId: String, userName: String) {
        if activeParticipants[studySessionId] == nil {
            activeParticipants[studySessionId] = []
        }
        activeParticipants[studySessionId]?.insert(userName)
        
        // Notify observers
        if let subject = participantsSubjects[studySessionId] {
            subject.send(Array(activeParticipants[studySessionId] ?? []))
        }
    }
    
    /// Leave a live session
    func leaveLiveSession(studySessionId: String, userId: String) {
        // In mock version, we don't track by userId, just clear all
        activeParticipants[studySessionId]?.removeAll()
        
        if let subject = participantsSubjects[studySessionId] {
            subject.send([])
        }
    }
    
    /// Observe active participants
    func observeActiveParticipants(sessionId: String, completion: @escaping ([String]) -> Void) {
        // Create subject if doesn't exist
        if participantsSubjects[sessionId] == nil {
            participantsSubjects[sessionId] = PassthroughSubject<[String], Never>()
        }
        
        // Subscribe to updates
        participantsSubjects[sessionId]?
            .sink { participants in
                completion(participants)
            }
            .store(in: &cancellables)
        
        // Send current state
        let participants = Array(activeParticipants[sessionId] ?? [])
        completion(participants)
    }
    
    // MARK: - Whiteboard Management
    
    /// Add a stroke to the whiteboard
    func addWhiteboardStroke(sessionId: String, stroke: WhiteboardStroke, completion: @escaping (Bool) -> Void) {
        if whiteboardStates[sessionId] == nil {
            whiteboardStates[sessionId] = WhiteboardState()
        }
        
        whiteboardStates[sessionId]?.strokes.append(stroke)
        whiteboardStates[sessionId]?.lastUpdatedBy = stroke.userId
        whiteboardStates[sessionId]?.lastUpdatedAt = Date()
        
        // Notify observers
        if let state = whiteboardStates[sessionId],
           let subject = whiteboardSubjects[sessionId] {
            subject.send(state)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Clear the whiteboard
    func clearWhiteboard(sessionId: String, completion: @escaping (Bool) -> Void) {
        whiteboardStates[sessionId] = WhiteboardState()
        
        // Notify observers
        if let state = whiteboardStates[sessionId],
           let subject = whiteboardSubjects[sessionId] {
            subject.send(state)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Observe whiteboard state
    func observeWhiteboardState(sessionId: String, completion: @escaping (WhiteboardState) -> Void) {
        // Create subject if doesn't exist
        if whiteboardSubjects[sessionId] == nil {
            whiteboardSubjects[sessionId] = PassthroughSubject<WhiteboardState, Never>()
        }
        
        // Subscribe to updates
        whiteboardSubjects[sessionId]?
            .sink { state in
                completion(state)
            }
            .store(in: &cancellables)
        
        // Send current state
        let state = whiteboardStates[sessionId] ?? WhiteboardState()
        completion(state)
    }
    
    // MARK: - Pomodoro Timer Management
    
    /// Update Pomodoro timer state
    func updatePomodoroState(sessionId: String, state: PomodoroState, completion: @escaping (Bool) -> Void) {
        pomodoroStates[sessionId] = state
        
        // Notify observers
        if let subject = pomodoroSubjects[sessionId] {
            subject.send(state)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Observe Pomodoro timer state
    func observePomodoroState(sessionId: String, completion: @escaping (PomodoroState) -> Void) {
        // Create subject if doesn't exist
        if pomodoroSubjects[sessionId] == nil {
            pomodoroSubjects[sessionId] = PassthroughSubject<PomodoroState, Never>()
        }
        
        // Subscribe to updates
        pomodoroSubjects[sessionId]?
            .sink { state in
                completion(state)
            }
            .store(in: &cancellables)
        
        // Send current state
        let state = pomodoroStates[sessionId] ?? PomodoroState()
        completion(state)
    }
    
    // MARK: - Live Poll Management
    
    /// Create a new poll
    func createPoll(sessionId: String, poll: LivePoll, completion: @escaping (Bool) -> Void) {
        currentPolls[sessionId] = poll
        
        // Notify observers
        if let subject = pollSubjects[sessionId] {
            subject.send(poll)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Submit a vote for a poll
    func submitPollVote(sessionId: String, pollId: String, userId: String, optionIndex: Int, completion: @escaping (Bool) -> Void) {
        guard var poll = currentPolls[sessionId] else {
            completion(false)
            return
        }
        
        // Add vote
        poll.votes[userId] = optionIndex
        
        // Update option vote count
        if optionIndex < poll.options.count {
            poll.options[optionIndex].voteCount += 1
        }
        
        currentPolls[sessionId] = poll
        
        // Notify observers
        if let subject = pollSubjects[sessionId] {
            subject.send(poll)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Close a poll
    func closePoll(sessionId: String, pollId: String, completion: @escaping (Bool) -> Void) {
        guard var poll = currentPolls[sessionId] else {
            completion(false)
            return
        }
        
        poll.isActive = false
        poll.closedAt = Date()
        currentPolls[sessionId] = poll
        
        // Notify observers
        if let subject = pollSubjects[sessionId] {
            subject.send(poll)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Observe current poll
    func observeCurrentPoll(sessionId: String, completion: @escaping (LivePoll?) -> Void) {
        // Create subject if doesn't exist
        if pollSubjects[sessionId] == nil {
            pollSubjects[sessionId] = PassthroughSubject<LivePoll?, Never>()
        }
        
        // Subscribe to updates
        pollSubjects[sessionId]?
            .sink { poll in
                completion(poll)
            }
            .store(in: &cancellables)
        
        // Send current state
        completion(currentPolls[sessionId])
    }
    
    // MARK: - Live Quiz Management
    
    /// Create a new quiz
    func createQuiz(sessionId: String, quiz: LiveQuiz, completion: @escaping (Bool) -> Void) {
        currentQuizzes[sessionId] = quiz
        
        // Notify observers
        if let subject = quizSubjects[sessionId] {
            subject.send(quiz)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Submit an answer for a quiz question
    func submitQuizAnswer(sessionId: String, quizId: String, questionIndex: Int, userId: String, answerIndex: Int, completion: @escaping (Bool) -> Void) {
        guard var quiz = currentQuizzes[sessionId] else {
            completion(false)
            return
        }
        
        guard questionIndex < quiz.questions.count else {
            completion(false)
            return
        }
        
        // Add answer
        quiz.questions[questionIndex].answers[userId] = answerIndex
        
        // Check if answer is correct and update score
        if answerIndex == quiz.questions[questionIndex].correctAnswerIndex {
            let currentScore = quiz.participantScores[userId] ?? 0
            quiz.participantScores[userId] = currentScore + 1
        }
        
        currentQuizzes[sessionId] = quiz
        
        // Notify observers
        if let subject = quizSubjects[sessionId] {
            subject.send(quiz)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Advance to next question
    func nextQuizQuestion(sessionId: String, quizId: String, completion: @escaping (Bool) -> Void) {
        guard var quiz = currentQuizzes[sessionId] else {
            completion(false)
            return
        }
        
        quiz.currentQuestionIndex += 1
        currentQuizzes[sessionId] = quiz
        
        // Notify observers
        if let subject = quizSubjects[sessionId] {
            subject.send(quiz)
        }
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    /// Observe current quiz
    func observeCurrentQuiz(sessionId: String, completion: @escaping (LiveQuiz?) -> Void) {
        // Create subject if doesn't exist
        if quizSubjects[sessionId] == nil {
            quizSubjects[sessionId] = PassthroughSubject<LiveQuiz?, Never>()
        }
        
        // Subscribe to updates
        quizSubjects[sessionId]?
            .sink { quiz in
                completion(quiz)
            }
            .store(in: &cancellables)
        
        // Send current state
        completion(currentQuizzes[sessionId])
    }
    
    // MARK: - Cleanup
    
    /// Remove all listeners
    nonisolated func removeAllListeners() {
        cancellables.removeAll()
        whiteboardSubjects.removeAll()
        pomodoroSubjects.removeAll()
        participantsSubjects.removeAll()
        pollSubjects.removeAll()
        quizSubjects.removeAll()
    }
    
    deinit {
        removeAllListeners()
    }
}
