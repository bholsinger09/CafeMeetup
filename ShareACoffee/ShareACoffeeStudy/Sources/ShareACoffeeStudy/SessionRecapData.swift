import Foundation
import SwiftUI

/// Session Recap Data - Aggregates all session statistics for shareable highlights
public struct SessionRecapData: Identifiable, Codable {
    public let id: String
    public let studySession: StudySession
    public let sessionDuration: TimeInterval
    public let participantCount: Int
    public let participantNames: [String]
    
    // Pomodoro Stats
    public var pomodoroStats: PomodoroStats?
    
    // Whiteboard Stats
    public var whiteboardStats: WhiteboardStats?
    
    // Poll Results
    public var topPolls: [PollSummary]
    
    // Quiz Results
    public var quizSummary: QuizSummary?
    
    public let completedAt: Date
    
    public struct PomodoroStats: Codable {
        public let completedPomodoros: Int
        public let totalFocusMinutes: Int
        public let totalBreakMinutes: Int
        public let longestFocusStreak: Int
        
        public var totalFocusTime: String {
            let hours = totalFocusMinutes / 60
            let mins = totalFocusMinutes % 60
            return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
        }
    }
    
    public struct WhiteboardStats: Codable {
        public let totalStrokes: Int
        public let contributingUsers: Int
        public let mostActiveUser: String
        public let mostActiveUserStrokes: Int
        public let strokePreview: [WhiteboardStroke]? // Last N strokes for preview
        
        public var hasContent: Bool {
            totalStrokes > 0
        }
    }
    
    public struct PollSummary: Identifiable, Codable {
        public let id: String
        public let question: String
        public let totalVotes: Int
        public let topOption: String
        public let topOptionVotes: Int
        public let participantCount: Int
        
        public var topOptionPercentage: Int {
            guard totalVotes > 0 else { return 0 }
            return Int(Double(topOptionVotes) / Double(totalVotes) * 100)
        }
    }
    
    public struct QuizSummary: Codable {
        public let title: String
        public let totalQuestions: Int
        public let participantCount: Int
        public let averageScore: Double
        public let topScorers: [LeaderboardEntry]
        public let completionRate: Int // Percentage
        
        public struct LeaderboardEntry: Identifiable, Codable {
            public let id: String
            public let userId: String
            public let userName: String
            public let score: Int
            public let rank: Int
            
            var medalEmoji: String {
                switch rank {
                case 1: return "🥇"
                case 2: return "🥈"
                case 3: return "🥉"
                default: return ""
                }
            }
        }
        
        public var averageScorePercentage: Int {
            guard totalQuestions > 0 else { return 0 }
            return Int((averageScore / Double(totalQuestions)) * 100)
        }
    }
    
    init(
        id: String = UUID().uuidString,
        studySession: StudySession,
        sessionDuration: TimeInterval,
        participantCount: Int,
        participantNames: [String],
        pomodoroStats: PomodoroStats? = nil,
        whiteboardStats: WhiteboardStats? = nil,
        topPolls: [PollSummary] = [],
        quizSummary: QuizSummary? = nil,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.studySession = studySession
        self.sessionDuration = sessionDuration
        self.participantCount = participantCount
        self.participantNames = participantNames
        self.pomodoroStats = pomodoroStats
        self.whiteboardStats = whiteboardStats
        self.topPolls = topPolls
        self.quizSummary = quizSummary
        self.completedAt = completedAt
    }
    
    public var sessionDurationFormatted: String {
        let hours = Int(sessionDuration) / 3600
        let minutes = (Int(sessionDuration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    public var hasAnyData: Bool {
        pomodoroStats != nil || 
        whiteboardStats?.hasContent == true || 
        !topPolls.isEmpty || 
        quizSummary != nil
    }
    
    public var highlightCount: Int {
        var count = 0
        if pomodoroStats != nil { count += 1 }
        if whiteboardStats?.hasContent == true { count += 1 }
        count += topPolls.count
        if quizSummary != nil { count += 1 }
        return count
    }
}

// MARK: - Sample Data for Previews

extension SessionRecapData {
    static var sample: SessionRecapData {
        SessionRecapData(
            studySession: .sample,
            sessionDuration: 7200, // 2 hours
            participantCount: 5,
            participantNames: ["Alice", "Bob", "Charlie", "Diana", "Eve"],
            pomodoroStats: PomodoroStats(
                completedPomodoros: 4,
                totalFocusMinutes: 100,
                totalBreakMinutes: 20,
                longestFocusStreak: 2
            ),
            whiteboardStats: WhiteboardStats(
                totalStrokes: 45,
                contributingUsers: 4,
                mostActiveUser: "Alice",
                mostActiveUserStrokes: 18,
                strokePreview: nil
            ),
            topPolls: [
                PollSummary(
                    id: UUID().uuidString,
                    question: "Which topic should we focus on next?",
                    totalVotes: 5,
                    topOption: "Recursion",
                    topOptionVotes: 3,
                    participantCount: 5
                ),
                PollSummary(
                    id: UUID().uuidString,
                    question: "5 minute or 10 minute break?",
                    totalVotes: 5,
                    topOption: "5 minutes",
                    topOptionVotes: 4,
                    participantCount: 5
                )
            ],
            quizSummary: QuizSummary(
                title: "Data Structures Quiz",
                totalQuestions: 10,
                participantCount: 5,
                averageScore: 7.8,
                topScorers: [
                    QuizSummary.LeaderboardEntry(id: "1", userId: "u1", userName: "Alice", score: 10, rank: 1),
                    QuizSummary.LeaderboardEntry(id: "2", userId: "u2", userName: "Bob", score: 9, rank: 2),
                    QuizSummary.LeaderboardEntry(id: "3", userId: "u3", userName: "Charlie", score: 8, rank: 3)
                ],
                completionRate: 100
            )
        )
    }
}

extension StudySession {
    static var sample: StudySession {
        StudySession(
            id: UUID().uuidString,
            hostId: "host123",
            hostName: "Alice",
            courseCode: "CS 101",
            courseName: "Introduction to Programming",
            studyTopic: "Recursion & Dynamic Programming",
            cafeId: "cafe123",
            cafeName: "Central Perk Coffee",
            scheduledDate: Date(),
            duration: 120,
            attendeeIds: ["u1", "u2", "u3", "u4", "u5"],
            attendeeNames: ["u1": "Alice", "u2": "Bob", "u3": "Charlie", "u4": "Diana", "u5": "Eve"],
            minAttendees: 3,
            maxAttendees: 6,
            isPublic: true,
            status: .completed
        )
    }
}
