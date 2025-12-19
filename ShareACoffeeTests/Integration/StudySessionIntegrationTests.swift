import XCTest
@testable import CafeMeetup

final class StudySessionIntegrationTests: XCTestCase {
    
    // MARK: - Study Session Item Tests
    
    func testStudySessionItemInitialization() {
        // Given
        let subject = "Computer Science"
        let topic = "Data Structures"
        let date = Date()
        let duration = 90
        let createdAt = Date()
        
        // When
        let session = StudySessionItem(
            subject: subject,
            topic: topic,
            date: date,
            duration: duration,
            createdAt: createdAt
        )
        
        // Then
        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.subject, subject)
        XCTAssertEqual(session.topic, topic)
        XCTAssertEqual(session.date, date)
        XCTAssertEqual(session.duration, duration)
        XCTAssertEqual(session.createdAt, createdAt)
    }
    
    func testStudySessionItemConformsToIdentifiable() {
        // Given
        let session = StudySessionItem(
            subject: "Mathematics",
            topic: "Calculus",
            date: Date(),
            duration: 60,
            createdAt: Date()
        )
        
        // Then
        XCTAssertNotNil(session.id)
    }
    
    func testStudySessionItemUniqueIds() {
        // When
        let session1 = StudySessionItem(
            subject: "Mathematics",
            topic: "Algebra",
            date: Date(),
            duration: 60,
            createdAt: Date()
        )
        
        let session2 = StudySessionItem(
            subject: "Mathematics",
            topic: "Algebra",
            date: Date(),
            duration: 60,
            createdAt: Date()
        )
        
        // Then
        XCTAssertNotEqual(session1.id, session2.id, "Each session should have a unique ID")
    }
    
    func testStudySessionItemWithEmptyTopic() {
        // Given
        let session = StudySessionItem(
            subject: "Biology",
            topic: "",
            date: Date(),
            duration: 120,
            createdAt: Date()
        )
        
        // Then
        XCTAssertTrue(session.topic.isEmpty)
        XCTAssertFalse(session.subject.isEmpty)
    }
    
    func testStudySessionItemDurationOptions() {
        // Test valid duration options
        let durations = [30, 60, 90, 120]
        
        for duration in durations {
            let session = StudySessionItem(
                subject: "Engineering",
                topic: "Thermodynamics",
                date: Date(),
                duration: duration,
                createdAt: Date()
            )
            
            XCTAssertEqual(session.duration, duration)
        }
    }
    
    func testStudySessionItemSubjects() {
        // Test that all expected subjects can be used
        let subjects = [
            "Computer Science", "Mathematics", "Biology", "Chemistry",
            "Physics", "Engineering", "Business", "Psychology",
            "English", "History", "Art", "Music", "Languages",
            "Economics", "Nursing", "Other"
        ]
        
        for subject in subjects {
            let session = StudySessionItem(
                subject: subject,
                topic: "Test Topic",
                date: Date(),
                duration: 60,
                createdAt: Date()
            )
            
            XCTAssertEqual(session.subject, subject)
        }
    }
    
    func testStudySessionItemDateInFuture() {
        // Given
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        
        // When
        let session = StudySessionItem(
            subject: "Computer Science",
            topic: "Algorithms",
            date: futureDate,
            duration: 90,
            createdAt: Date()
        )
        
        // Then
        XCTAssertGreaterThan(session.date, Date())
    }
    
    // MARK: - Study Session Creation Flow Tests
    
    func testStudySessionCreationCallbackFlow() {
        // Given
        var createdSession: StudySessionItem?
        var callbackInvoked = false
        
        let onCreate: (StudySessionItem) -> Void = { session in
            createdSession = session
            callbackInvoked = true
        }
        
        // When
        let session = StudySessionItem(
            subject: "Physics",
            topic: "Quantum Mechanics",
            date: Date(),
            duration: 120,
            createdAt: Date()
        )
        onCreate(session)
        
        // Then
        XCTAssertTrue(callbackInvoked)
        XCTAssertNotNil(createdSession)
        XCTAssertEqual(createdSession?.subject, "Physics")
        XCTAssertEqual(createdSession?.topic, "Quantum Mechanics")
    }
    
    func testStudySessionListManagement() {
        // Given
        var sessions: [StudySessionItem] = []
        
        // When - Create multiple sessions
        let session1 = StudySessionItem(
            subject: "Mathematics",
            topic: "Linear Algebra",
            date: Date(),
            duration: 60,
            createdAt: Date()
        )
        sessions.append(session1)
        
        let session2 = StudySessionItem(
            subject: "Computer Science",
            topic: "Machine Learning",
            date: Date(),
            duration: 90,
            createdAt: Date()
        )
        sessions.append(session2)
        
        // Then
        XCTAssertEqual(sessions.count, 2)
        XCTAssertEqual(sessions[0].subject, "Mathematics")
        XCTAssertEqual(sessions[1].subject, "Computer Science")
    }
    
    func testStudySessionFiltering() {
        // Given
        var sessions: [StudySessionItem] = []
        
        sessions.append(StudySessionItem(
            subject: "Mathematics",
            topic: "Calculus",
            date: Date(),
            duration: 60,
            createdAt: Date()
        ))
        
        sessions.append(StudySessionItem(
            subject: "Computer Science",
            topic: "Algorithms",
            date: Date(),
            duration: 90,
            createdAt: Date()
        ))
        
        sessions.append(StudySessionItem(
            subject: "Mathematics",
            topic: "Statistics",
            date: Date(),
            duration: 60,
            createdAt: Date()
        ))
        
        // When
        let mathSessions = sessions.filter { $0.subject == "Mathematics" }
        let csSessions = sessions.filter { $0.subject == "Computer Science" }
        
        // Then
        XCTAssertEqual(mathSessions.count, 2)
        XCTAssertEqual(csSessions.count, 1)
    }
    
    func testStudySessionSorting() {
        // Given
        let now = Date()
        let sessions = [
            StudySessionItem(
                subject: "Mathematics",
                topic: "Algebra",
                date: now.addingTimeInterval(7200), // 2 hours later
                duration: 60,
                createdAt: now
            ),
            StudySessionItem(
                subject: "Physics",
                topic: "Mechanics",
                date: now.addingTimeInterval(3600), // 1 hour later
                duration: 60,
                createdAt: now
            ),
            StudySessionItem(
                subject: "Chemistry",
                topic: "Organic",
                date: now.addingTimeInterval(10800), // 3 hours later
                duration: 60,
                createdAt: now
            )
        ]
        
        // When
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        
        // Then
        XCTAssertEqual(sortedSessions[0].subject, "Physics")
        XCTAssertEqual(sortedSessions[1].subject, "Mathematics")
        XCTAssertEqual(sortedSessions[2].subject, "Chemistry")
    }
    
    // MARK: - Performance Tests
    
    func testStudySessionCreationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = StudySessionItem(
                    subject: "Computer Science",
                    topic: "Algorithms",
                    date: Date(),
                    duration: 60,
                    createdAt: Date()
                )
            }
        }
    }
    
    func testStudySessionFilteringPerformance() {
        // Given
        var sessions: [StudySessionItem] = []
        for i in 0..<1000 {
            let subject = i % 2 == 0 ? "Mathematics" : "Computer Science"
            sessions.append(StudySessionItem(
                subject: subject,
                topic: "Topic \(i)",
                date: Date(),
                duration: 60,
                createdAt: Date()
            ))
        }
        
        // Measure filtering performance
        measure {
            _ = sessions.filter { $0.subject == "Mathematics" }
        }
    }
    
    // MARK: - Edge Cases
    
    func testStudySessionWithMaxDuration() {
        // Given
        let session = StudySessionItem(
            subject: "Engineering",
            topic: "Project Work",
            date: Date(),
            duration: 120,
            createdAt: Date()
        )
        
        // Then
        XCTAssertEqual(session.duration, 120)
    }
    
    func testStudySessionWithMinDuration() {
        // Given
        let session = StudySessionItem(
            subject: "Quick Review",
            topic: "Vocabulary",
            date: Date(),
            duration: 30,
            createdAt: Date()
        )
        
        // Then
        XCTAssertEqual(session.duration, 30)
    }
    
    func testStudySessionWithLongTopic() {
        // Given
        let longTopic = String(repeating: "A", count: 200)
        
        // When
        let session = StudySessionItem(
            subject: "Literature",
            topic: longTopic,
            date: Date(),
            duration: 60,
            createdAt: Date()
        )
        
        // Then
        XCTAssertEqual(session.topic.count, 200)
    }
}
