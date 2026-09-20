import Foundation
import SwiftUI

/// Live Session - Real-time collaborative features during active study sessions
public struct LiveSession: Identifiable, Codable, Equatable {
    public let id: String
    public let studySessionId: String
    public var isActive: Bool
    public var activeParticipants: [String] // User IDs currently online
    public var pomodoroState: PomodoroState?
    public var currentPollId: String?
    public var whiteboardState: WhiteboardState?
    public let createdAt: Date
    public var updatedAt: Date
    
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
public struct PomodoroState: Codable, Equatable {
    public var isRunning: Bool
    public var currentPhase: PomodoroPhase
    public var secondsRemaining: Int
    public var completedPomodoros: Int
    public var startedAt: Date?
    public var pausedAt: Date?
    
    public enum PomodoroPhase: String, Codable {
        case work = "Focus Time"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
        
        public var duration: Int {
            switch self {
            case .work: return 25 * 60 // 25 minutes
            case .shortBreak: return 5 * 60 // 5 minutes
            case .longBreak: return 15 * 60 // 15 minutes
            }
        }
        
        public var color: Color {
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
public struct WhiteboardState: Codable, Equatable {
    public var strokes: [WhiteboardStroke]
    public var backgroundColor: String // Hex color
    public var lastUpdatedBy: String? // User ID
    public var lastUpdatedAt: Date
    
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
public struct WhiteboardStroke: Identifiable, Codable, Equatable {
    public let id: String
    public let userId: String
    public let userName: String
    public var points: [CGPointCodable]
    public var color: String // Hex color
    public var lineWidth: Double
    public let createdAt: Date
    
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
public struct CGPointCodable: Codable, Equatable {
    public let x: Double
    public let y: Double
    
    public var cgPoint: CGPoint {
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
    public let id: String
    public let studySessionId: String
    public let createdBy: String
    public let createdByName: String
    public let question: String
    public var options: [PollOption]
    public var votes: [String: Int] // [userId: optionIndex]
    public let allowMultipleVotes: Bool
    public let isAnonymous: Bool
    public var isActive: Bool
    public let createdAt: Date
    public var closedAt: Date?
    
    struct PollOption: Codable, Equatable, Identifiable {
        public let id: String
        public let text: String
        public var voteCount: Int
        
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
    public let id: String
    public let studySessionId: String
    public let createdBy: String
    public let createdByName: String
    public let title: String
    public var questions: [QuizQuestion]
    public var currentQuestionIndex: Int
    public var participantScores: [String: Int] // [userId: score]
    public var isActive: Bool
    public let createdAt: Date
    public var completedAt: Date?
    
    struct QuizQuestion: Identifiable, Codable, Equatable {
        public let id: String
        public let question: String
        public let options: [String]
        public let correctAnswerIndex: Int
        public var answers: [String: Int] // [userId: selectedIndex]
        public let timeLimit: Int? // seconds
        public var revealedAt: Date?
        
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
