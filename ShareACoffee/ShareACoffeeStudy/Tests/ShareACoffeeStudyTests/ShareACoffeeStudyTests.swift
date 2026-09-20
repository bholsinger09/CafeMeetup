import XCTest
@testable import ShareACoffeeStudy
import ShareACoffeeCore

final class ShareACoffeeStudyTests: XCTestCase {
    
    func testStudySessionModelInitialization() {
        let session = StudySession(
            id: "session-1",
            hostId: "host-123",
            hostName: "Jane Smith",
            title: "Math Midterm Prep",
            description: "Preparing for calculus midterm",
            subject: "Mathematics",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            location: "Coffee Shop",
            maxAttendees: 5,
            attendeeIds: [],
            isVirtual: false
        )
        XCTAssertEqual(session.id, "session-1")
        XCTAssertEqual(session.title, "Math Midterm Prep")
    }
    
    func testStudySessionServiceExists() {
        let service = StudySessionService.shared
        XCTAssertNotNil(service)
    }
    
    func testLiveSessionServiceExists() {
        let service = LiveSessionService.shared
        XCTAssertNotNil(service)
    }
    
    func testSessionRecapServiceExists() {
        let service = SessionRecapService.shared
        XCTAssertNotNil(service)
    }
}
