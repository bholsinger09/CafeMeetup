import Foundation
import SwiftUI

/// Session Recap Data - Aggregates all session statistics for shareable highlights
struct SessionRecapData: Identifiable, Codable {
    let id: String
    let studySession: StudySession
    let sessionDuration: TimeInterval
    let participantCount: Int
    let participantNames: [String]
    
    // Pomodoro Stats
    var pomodoroStats: PomodoroStats?
    
    // Whiteboard Stats
    var whiteboardStats: WhiteboardStats?
    
    // Poll Results
    var topPolls: [PollSummary]
    
    // Quiz Results
    var quizSummary: QuizSummary?
    
    let completedAt: Date
    
    struct PomodoroStats: Codable {
        let completedPomodoros: Int
        let totalFocusMinutes: Int
        let totalBreakMinutes: Int
        let longestFocusStreak: Int
        
        var totalFocusTime: String {
            let hours = totalFocusMinutes / 60
            let mins = totalFocusMinutes % 60
            return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
        }
    }
    
    struct WhiteboardStats: Codable {
        let totalStrokes: Int
        let contributingUsers: Int
        let mostActiveUser: String
        let mostActiveUserStrokes: Int
        let strokePreview: [WhiteboardStroke]? // Last N strokes for preview
        
        var hasContent: Bool {
            totalStrokes > 0
        }
    }
    
    struct PollSummary: Identifiable, Codable {
        let id: String
        let question: String
        let totalVotes: Int
        let topOption: String
        let topOptionVotes: Int
        let participantCount: Int
        
        var topOptionPercentage: Int {
            guard totalVotes > 0 else { return 0 }
            return Int(Double(topOptionVotes) / Double(totalVotes) * 100)
        }
    }
    
    struct QuizSummary: Codable {
        let title: String
        let totalQuestions: Int
        let participantCount: Int
        let averageScore: Double
        let topScorers: [LeaderboardEntry]
        let completionRate: Int // Percentage
        
        struct LeaderboardEntry: Identifiable, Codable {
            let id: String
            let userId: String
            let userName: String
            let score: Int
            let rank: Int
            
            var medalEmoji: String {
                switch rank {
                case 1: return "🥇"
                case 2: return "🥈"
                case 3: return "🥉"
                default: return ""
                }
            }
        }
        
        var averageScorePercentage: Int {
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
    
    var sessionDurationFormatted: String {
        let hours = Int(sessionDuration) / 3600
        let minutes = (Int(sessionDuration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var hasAnyData: Bool {
        pomodoroStats != nil || 
        whiteboardStats?.hasContent == true || 
        !topPolls.isEmpty || 
        quizSummary != nil
    }
    
    var highlightCount: Int {
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
