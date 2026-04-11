import Foundation
import SwiftUI

/// Live Session - Real-time collaborative features during active study sessions
struct LiveSession: Identifiable, Codable, Equatable {
    let id: String
    let studySessionId: String
    var isActive: Bool
    var activeParticipants: [String] // User IDs currently online
    var pomodoroState: PomodoroState?
    var currentPollId: String?
    var whiteboardState: WhiteboardState?
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        studySessionId: String,
        isActive: Bool = false,
        activeParticipants: [String] = [],
        pomodoroState: PomodoroState? = nil,
        currentPollId: String? = nil,
        whiteboardState: WhiteboardState? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.studySessionId = studySessionId
        self.isActive = isActive
        self.activeParticipants = activeParticipants
        self.pomodoroState = pomodoroState
        self.currentPollId = currentPollId
        self.whiteboardState = whiteboardState
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Pomodoro Timer State - Synchronized across all participants
struct PomodoroState: Codable, Equatable {
    var isRunning: Bool
    var currentPhase: PomodoroPhase
    var secondsRemaining: Int
    var completedPomodoros: Int
    var startedAt: Date?
    var pausedAt: Date?
    
    enum PomodoroPhase: String, Codable {
        case work = "Focus Time"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
        
        var duration: Int {
            switch self {
            case .work: return 25 * 60 // 25 minutes
            case .shortBreak: return 5 * 60 // 5 minutes
            case .longBreak: return 15 * 60 // 15 minutes
            }
        }
        
        var color: Color {
            switch self {
            case .work: return .red
            case .shortBreak: return .green
            case .longBreak: return .blue
            }
        }
    }
    
    init(
        isRunning: Bool = false,
        currentPhase: PomodoroPhase = .work,
        secondsRemaining: Int = 25 * 60,
        completedPomodoros: Int = 0,
        startedAt: Date? = nil,
        pausedAt: Date? = nil
    ) {
        self.isRunning = isRunning
        self.currentPhase = currentPhase
        self.secondsRemaining = secondsRemaining
        self.completedPomodoros = completedPomodoros
        self.startedAt = startedAt
        self.pausedAt = pausedAt
    }
}

/// Whiteboard State - Tracks the collaborative drawing canvas
struct WhiteboardState: Codable, Equatable {
    var strokes: [WhiteboardStroke]
    var backgroundColor: String // Hex color
    var lastUpdatedBy: String? // User ID
    var lastUpdatedAt: Date
    
    init(
        strokes: [WhiteboardStroke] = [],
        backgroundColor: String = "#FFFFFF",
        lastUpdatedBy: String? = nil,
        lastUpdatedAt: Date = Date()
    ) {
        self.strokes = strokes
        self.backgroundColor = backgroundColor
        self.lastUpdatedBy = lastUpdatedBy
        self.lastUpdatedAt = lastUpdatedAt
    }
}

/// Individual stroke on the whiteboard
struct WhiteboardStroke: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let userName: String
    var points: [CGPointCodable]
    var color: String // Hex color
    var lineWidth: Double
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        userName: String,
        points: [CGPointCodable] = [],
        color: String = "#000000",
        lineWidth: Double = 3.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.createdAt = createdAt
    }
}

/// Codable wrapper for CGPoint
struct CGPointCodable: Codable, Equatable {
    let x: Double
    let y: Double
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
}

/// Live Poll for quick voting during study sessions
struct LivePoll: Identifiable, Codable, Equatable {
    let id: String
    let studySessionId: String
    let createdBy: String
    let createdByName: String
    let question: String
    var options: [PollOption]
    var votes: [String: Int] // [userId: optionIndex]
    let allowMultipleVotes: Bool
    let isAnonymous: Bool
    var isActive: Bool
    let createdAt: Date
    var closedAt: Date?
    
    struct PollOption: Codable, Equatable, Identifiable {
        let id: String
        let text: String
        var voteCount: Int
        
        init(id: String = UUID().uuidString, text: String, voteCount: Int = 0) {
            self.id = id
            self.text = text
            self.voteCount = voteCount
        }
    }
    
    init(
        id: String = UUID().uuidString,
        studySessionId: String,
        createdBy: String,
        createdByName: String,
        question: String,
        options: [PollOption],
        votes: [String: Int] = [:],
        allowMultipleVotes: Bool = false,
        isAnonymous: Bool = false,
        isActive: Bool = true,
        createdAt: Date = Date(),
        closedAt: Date? = nil
    ) {
        self.id = id
        self.studySessionId = studySessionId
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.question = question
        self.options = options
        self.votes = votes
        self.allowMultipleVotes = allowMultipleVotes
        self.isAnonymous = isAnonymous
        self.isActive = isActive
        self.createdAt = createdAt
        self.closedAt = closedAt
    }
}

/// Live Quiz for group learning
struct LiveQuiz: Identifiable, Codable, Equatable {
    let id: String
    let studySessionId: String
    let createdBy: String
    let createdByName: String
    let title: String
    var questions: [QuizQuestion]
    var currentQuestionIndex: Int
    var participantScores: [String: Int] // [userId: score]
    var isActive: Bool
    let createdAt: Date
    var completedAt: Date?
    
    struct QuizQuestion: Identifiable, Codable, Equatable {
        let id: String
        let question: String
        let options: [String]
        let correctAnswerIndex: Int
        var answers: [String: Int] // [userId: selectedIndex]
        let timeLimit: Int? // seconds
        var revealedAt: Date?
        
        init(
            id: String = UUID().uuidString,
            question: String,
            options: [String],
            correctAnswerIndex: Int,
            answers: [String: Int] = [:],
            timeLimit: Int? = 30,
            revealedAt: Date? = nil
        ) {
            self.id = id
            self.question = question
            self.options = options
            self.correctAnswerIndex = correctAnswerIndex
            self.answers = answers
            self.timeLimit = timeLimit
            self.revealedAt = revealedAt
        }
    }
    
    init(
        id: String = UUID().uuidString,
        studySessionId: String,
        createdBy: String,
        createdByName: String,
        title: String,
        questions: [QuizQuestion] = [],
        currentQuestionIndex: Int = 0,
        participantScores: [String: Int] = [:],
        isActive: Bool = true,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.studySessionId = studySessionId
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.title = title
        self.questions = questions
        self.currentQuestionIndex = currentQuestionIndex
        self.participantScores = participantScores
        self.isActive = isActive
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
