import Foundation
import ShareACoffeeCore
import ShareACoffeeStudy
import Combine
import CoreLocation

/// Service to manage unique StudyBrew features: study sessions, check-ins, and rewards
@MainActor
public class CoffeeExperienceService: ObservableObject {
    public static let shared = CoffeeExperienceService()
    
    @Published var studySessions: [StudySession] = []
    @Published var userRewards: [String: Int] = [:]
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Study Sessions
    
    func createStudySession(
        hostId: String,
        hostName: String,
        courseCode: String,
        courseName: String,
        studyTopic: String,
        cafeId: String,
        cafeName: String,
        scheduledDate: Date,
        duration: Int,
        maxAttendees: Int,
        isPublic: Bool
    ) async throws {
        let session = StudySession(
            id: UUID().uuidString,
            hostId: hostId,
            hostName: hostName,
            courseCode: courseCode,
            courseName: courseName,
            studyTopic: studyTopic,
            cafeId: cafeId,
            cafeName: cafeName,
            scheduledDate: scheduledDate,
            duration: duration,
            attendeeIds: [hostId],
            attendeeNames: [hostId: hostName],
            minAttendees: 3,
            maxAttendees: maxAttendees,
            isPublic: isPublic,
            status: .scheduled,
            createdAt: Date()
        )
        
        await MainActor.run {
            studySessions.append(session)
        }
    }
    
    func joinStudySession(_ sessionId: String, userId: String) async throws {
        guard let index = studySessions.firstIndex(where: { $0.id == sessionId }) else {
            throw CoffeeExperienceError.sessionNotFound
        }
        
        await MainActor.run {
            if !studySessions[index].attendeeIds.contains(userId) {
                studySessions[index].attendeeIds.append(userId)
            }
        }
    }
    
    func getUpcomingSessions(forUserId userId: String) -> [StudySession] {
        studySessions.filter { session in
            session.isUpcoming &&
            (session.isPublic || session.attendeeIds.contains(userId))
        }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    func getPublicSessions(courseCode: String? = nil) -> [StudySession] {
        var sessions = studySessions.filter { $0.isPublic && $0.isUpcoming && !$0.isFull }
        
        if let courseCode = courseCode {
            sessions = sessions.filter { $0.courseCode == courseCode }
        }
        
        return sessions.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        let session1 = StudySession(
            id: "session1",
            hostId: "user1",
            hostName: "Sarah",
            courseCode: "CS 101",
            courseName: "Introduction to Computer Science",
            studyTopic: "Data Structures & Algorithms",
            cafeId: "cafe1",
            cafeName: "The Human Bean",
            scheduledDate: Date().addingTimeInterval(86400),
            duration: 120,
            attendeeIds: ["user1"],
            attendeeNames: ["user1": "Sarah"],
            minAttendees: 3,
            maxAttendees: 4,
            isPublic: true,
            status: .scheduled,
            createdAt: Date()
        )
        
        studySessions.append(session1)
    }
}

enum CoffeeExperienceError: LocalizedError {
    case sessionNotFound
    case sessionFull
    case alreadyJoined
    case checkInFailed
    
    var errorDescription: String? {
        switch self {
        case .sessionNotFound: return "Study session not found."
        case .sessionFull: return "This study session is full."
        case .alreadyJoined: return "You've already joined this session."
        case .checkInFailed: return "Failed to check in. Please try again."
        }
    }
}
