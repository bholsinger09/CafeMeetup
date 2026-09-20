import XCTest
@testable import ShareACoffeeStudy
@testable import ShareACoffeeCore

/// Tests to validate Study package imports and type accessibility
class StudyPackageValidationTests: XCTestCase {
    
    // MARK: - Type Accessibility Tests
    
    func testStudySessionCanAccessUserType() {
        let session = StudySession(
            id: "session123",
            hostId: "user1",
            title: "CS 101 Study Group",
            description: "Studying algorithms",
            subject: "Computer Science",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            maxParticipants: 5,
            currentParticipants: 1,
            isVirtual: false
        )
        
        XCTAssertEqual(session.title, "CS 101 Study Group")
    }
    
    func testLiveSessionCanAccessUserType() {
        let session = LiveSession(
            id: "live123",
            hostId: "user1",
            title: "Live Coding Session",
            description: "Real-time coding challenge",
            startTime: Date(),
            endTime: Date().addingTimeInterval(7200),
            maxViewers: 100,
            currentViewers: 10,
            isActive: true
        )
        
        XCTAssertEqual(session.title, "Live Coding Session")
    }
    
    func testSessionRecapDataCanAccessUserType() {
        let recap = SessionRecapData(
            id: "recap123",
            sessionId: "session123",
            attendeeCount: 5,
            duration: 60,
            topicsCovered: ["Arrays", "Sorting"],
            keyTakeaways: ["Important concept 1"],
            nextSessionDate: Date()
        )
        
        XCTAssertEqual(recap.attendeeCount, 5)
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testStudySessionConformsToIdentifiable() {
        let session = StudySession(
            id: "session123",
            hostId: "user1",
            title: "CS 101 Study Group",
            description: "Studying algorithms",
            subject: "Computer Science",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            maxParticipants: 5,
            currentParticipants: 1,
            isVirtual: false
        )
        
        let _: AnyHashable = session.id
        XCTAssertNotNil(session.id)
    }
    
    func testLiveSessionConformsToIdentifiable() {
        let session = LiveSession(
            id: "live123",
            hostId: "user1",
            title: "Live Session",
            description: "Description",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            maxViewers: 100,
            currentViewers: 0,
            isActive: false
        )
        
        let _: AnyHashable = session.id
        XCTAssertNotNil(session.id)
    }
    
    // MARK: - Service Tests
    
    func testStudySessionServiceHasUserTypeAccess() {
        let service = StudySessionService()
        XCTAssertNotNil(service)
    }
    
    func testLiveSessionServiceHasUserTypeAccess() {
        let service = LiveSessionService()
        XCTAssertNotNil(service)
    }
    
    func testSessionRecapServiceHasUserTypeAccess() {
        let service = SessionRecapService()
        XCTAssertNotNil(service)
    }
    
    // MARK: - Cross-Package Tests
    
    func testStudyPackageDependsOnCore() {
        let user = User(
            id: "host123",
            firstName: "Study",
            lastName: "Host",
            email: "host@test.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: ["Computer Science"],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 4.5,
            createdAt: Date()
        )
        
        let session = StudySession(
            id: "session123",
            hostId: user.id,
            title: "CS Study Group",
            description: "Studying CS",
            subject: "Computer Science",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            maxParticipants: 5,
            currentParticipants: 1,
            isVirtual: false
        )
        
        XCTAssertEqual(session.hostId, user.id)
    }
}
