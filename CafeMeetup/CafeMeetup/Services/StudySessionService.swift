import Foundation
import Combine

/// Service for managing study sessions - the PRIMARY feature of LatteLink
/// Handles creating, joining, and managing group study sessions
class StudySessionService: ObservableObject {
    @Published var upcomingSessions: [StudySession] = []
    @Published var mySessions: [StudySession] = []
    @Published var publicSessions: [StudySession] = []
    @Published var completedSessions: [StudySession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let currentUserId: String
    
    init(userId: String) {
        self.currentUserId = userId
        loadMockData()
    }
    
    // MARK: - Create Study Session
    
    func createStudySession(
        courseCode: String,
        courseName: String,
        topic: String,
        cafeId: String,
        cafeName: String,
        date: Date,
        duration: Int,
        maxAttendees: Int,
        isPublic: Bool
    ) {
        let session = StudySession(
            hostId: currentUserId,
            hostName: "Current User",
            courseCode: courseCode,
            courseName: courseName,
            studyTopic: topic,
            cafeId: cafeId,
            cafeName: cafeName,
            scheduledDate: date,
            duration: duration,
            attendeeIds: [currentUserId],
            attendeeNames: [currentUserId: "Current User"],
            minAttendees: 3,
            maxAttendees: maxAttendees,
            isPublic: isPublic
        )
        
        upcomingSessions.insert(session, at: 0)
        mySessions.insert(session, at: 0)
        
        if isPublic {
            publicSessions.insert(session, at: 0)
        }
    }
    
    // MARK: - Join Study Session
    
    func joinSession(_ session: StudySession, userName: String) {
        guard !session.isFull else {
            errorMessage = "This study session is full"
            return
        }
        
        guard !session.attendeeIds.contains(currentUserId) else {
            errorMessage = "You're already in this session"
            return
        }
        
        if let index = upcomingSessions.firstIndex(where: { $0.id == session.id }) {
            upcomingSessions[index].attendeeIds.append(currentUserId)
            upcomingSessions[index].attendeeNames[currentUserId] = userName
            mySessions.insert(upcomingSessions[index], at: 0)
        }
        
        if let index = publicSessions.firstIndex(where: { $0.id == session.id }) {
            publicSessions[index].attendeeIds.append(currentUserId)
            publicSessions[index].attendeeNames[currentUserId] = userName
        }
    }
    
    // MARK: - Leave Study Session
    
    func leaveSession(_ session: StudySession) {
        if let index = upcomingSessions.firstIndex(where: { $0.id == session.id }) {
            upcomingSessions[index].attendeeIds.removeAll { $0 == currentUserId }
            upcomingSessions[index].attendeeNames.removeValue(forKey: currentUserId)
        }
        
        mySessions.removeAll { $0.id == session.id }
        
        if let index = publicSessions.firstIndex(where: { $0.id == session.id }) {
            publicSessions[index].attendeeIds.removeAll { $0 == currentUserId }
            publicSessions[index].attendeeNames.removeValue(forKey: currentUserId)
        }
    }
    
    // MARK: - Cancel Study Session
    
    func cancelSession(_ session: StudySession) {
        guard session.hostId == currentUserId else {
            errorMessage = "Only the host can cancel this session"
            return
        }
        
        if let index = upcomingSessions.firstIndex(where: { $0.id == session.id }) {
            upcomingSessions[index].status = .cancelled
        }
        
        if let index = mySessions.firstIndex(where: { $0.id == session.id }) {
            mySessions[index].status = .cancelled
        }
    }
    
    // MARK: - Complete Study Session
    
    func completeSession(_ session: StudySession, attendedUserIds: [String]) {
        if let index = upcomingSessions.firstIndex(where: { $0.id == session.id }) {
            upcomingSessions[index].status = .completed
            upcomingSessions[index].completedAttendees = attendedUserIds
            
            let completed = upcomingSessions[index]
            completedSessions.insert(completed, at: 0)
            upcomingSessions.remove(at: index)
        }
        
        if let index = mySessions.firstIndex(where: { $0.id == session.id }) {
            mySessions[index].status = .completed
            mySessions[index].completedAttendees = attendedUserIds
        }
    }
    
    // MARK: - Get Sessions by Course
    
    func sessions(forCourse courseCode: String) -> [StudySession] {
        publicSessions.filter { $0.courseCode == courseCode && $0.isUpcoming }
    }
    
    // MARK: - Statistics
    
    func totalStudyHours() -> Int {
        let completed = completedSessions.filter { $0.completedAttendees?.contains(currentUserId) ?? false }
        return completed.reduce(0) { $0 + $1.duration } / 60 // Convert minutes to hours
    }
    
    func studySessionsThisWeek() -> Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return completedSessions.filter { session in
            guard let attendees = session.completedAttendees else { return false }
            return attendees.contains(currentUserId) && session.scheduledDate >= weekAgo
        }.count
    }
    
    // MARK: - Mock Data for Testing
    
    private func loadMockData() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        
        let session1 = StudySession(
            id: "session1",
            hostId: "user1",
            hostName: "Sarah Miller",
            courseCode: "CS 101",
            courseName: "Introduction to Programming",
            studyTopic: "Chapter 5: Loops and Functions",
            cafeId: "cafe1",
            cafeName: "Campus Coffee Co.",
            scheduledDate: tomorrow,
            duration: 120,
            attendeeIds: ["user1", "user2", "user3"],
            attendeeNames: ["user1": "Sarah Miller", "user2": "Mike Chen", "user3": "Emma Davis"],
            minAttendees: 3,
            maxAttendees: 6,
            isPublic: true
        )
        
        let session2 = StudySession(
            id: "session2",
            hostId: "user4",
            hostName: "Alex Johnson",
            courseCode: "MATH 250",
            courseName: "Calculus II",
            studyTopic: "Midterm Review - Integration Techniques",
            cafeId: "cafe2",
            cafeName: "Brewed Awakening",
            scheduledDate: nextWeek,
            duration: 180,
            attendeeIds: ["user4", "user5"],
            attendeeNames: ["user4": "Alex Johnson", "user5": "Jessica Lee"],
            minAttendees: 3,
            maxAttendees: 5,
            isPublic: true
        )
        
        let session3 = StudySession(
            id: "session3",
            hostId: "user6",
            hostName: "David Park",
            courseCode: "CHEM 110",
            courseName: "General Chemistry",
            studyTopic: "Lab Report Discussion",
            cafeId: "cafe3",
            cafeName: "The Grind",
            scheduledDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            duration: 90,
            attendeeIds: ["user6", "user7", "user8", "user9"],
            attendeeNames: [
                "user6": "David Park",
                "user7": "Sophia Martinez",
                "user8": "Ryan Taylor",
                "user9": "Olivia Brown"
            ],
            minAttendees: 3,
            maxAttendees: 8,
            isPublic: true
        )
        
        upcomingSessions = [session1, session2, session3]
        publicSessions = [session1, session2, session3]
    }
}
