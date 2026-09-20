import XCTest
@testable import ShareACoffeeSocial
import ShareACoffeeCore

final class ShareACoffeeSocialTests: XCTestCase {
    
    func testMatchModelInitialization() {
        let match = Match(
            id: "match-1",
            userId1: "user1",
            userId2: "user2",
            matchPercentage: 85.5,
            commonInterests: ["Math", "Coffee"],
            createdAt: Date()
        )
        XCTAssertEqual(match.id, "match-1")
        XCTAssertEqual(match.matchPercentage, 85.5)
    }
    
    func testMessageModelInitialization() {
        let message = Message(
            id: "msg-1",
            senderId: "sender",
            recipientId: "recipient",
            content: "Hello!",
            timestamp: Date()
        )
        XCTAssertEqual(message.id, "msg-1")
        XCTAssertEqual(message.content, "Hello!")
    }
    
    func testMatchServiceExists() {
        let service = MatchService.shared
        XCTAssertNotNil(service)
    }
    
    func testMessageServiceExists() {
        let service = MessageService.shared
        XCTAssertNotNil(service)
    }
}
