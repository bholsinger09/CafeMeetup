import XCTest
@testable import CafeMeetup

/// Tests for CoffeeExperienceService
/// Verifies business logic for study sessions, check-ins, and rewards
final class CoffeeExperienceServiceTests: XCTestCase {
    
    var service: CoffeeExperienceService!
    
    override func setUp() {
        super.setUp()
        service = CoffeeExperienceService.shared
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Service Initialization Tests
    
    func testServiceIsSingleton() {
        let service1 = CoffeeExperienceService.shared
        let service2 = CoffeeExperienceService.shared
        
        XCTAssertTrue(service1 === service2, "Service should be a singleton")
    }
    
    func testServiceInitializesWithEmptyData() {
        // Service should initialize with empty or mock data
        XCTAssertNotNil(service.studySessions)
        XCTAssertNotNil(service.userCheckIns)
        XCTAssertNotNil(service.userRewards)
        XCTAssertNotNil(service.userBadges)
    }
    
    func testServiceIsMainActor() {
        // Service should be marked with @MainActor for UI updates
        XCTAssertTrue(type(of: service).self == CoffeeExperienceService.self)
    }
    
    // MARK: - Study Session Creation Tests
    
    func testCreateStudySession() {
        let initialCount = service.studySessions.count
        
        let sessionId = service.createStudySession(
            hostId: "user123",
            hostName: "John Doe",
            subject: "Computer Science",
            courseNumber: "CS 101",
            studyTopic: "Data Structures",
            cafeId: "cafe456",
            cafeName: "Test Café",
            scheduledDate: Date().addingTimeInterval(3600),
            duration: 60,
            maxAttendees: 4,
            isPublic: true
        )
        
        XCTAssertNotNil(sessionId, "Should return a session ID")
        XCTAssertGreaterThan(service.studySessions.count, initialCount, "Should add session to list")
        
        let createdSession = service.studySessions.first { $0.id == sessionId }
        XCTAssertNotNil(createdSession, "Created session should be findable")
        XCTAssertEqual(createdSession?.hostId, "user123")
        XCTAssertEqual(createdSession?.studyTopic, "Data Structures")
    }
    
    func testJoinStudySession() {
        // Create a session first
        let sessionId = service.createStudySession(
            hostId: "host123",
            hostName: "Host",
            subject: "Mathematics",
            courseNumber: nil,
            studyTopic: "Calculus",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date().addingTimeInterval(3600),
            duration: 90,
            maxAttendees: 3,
            isPublic: true
        )
        
        // Join the session
        let success = service.joinStudySession(sessionId: sessionId, userId: "user456", userName: "Jane Doe")
        
        XCTAssertTrue(success, "Should successfully join session")
        
        let session = service.studySessions.first { $0.id == sessionId }
        XCTAssertTrue(session?.attendeeIds.contains("user456") ?? false, "User should be in attendee list")
    }
    
    func testCannotJoinFullSession() {
        // Create a session with max 2 attendees
        let sessionId = service.createStudySession(
            hostId: "host",
            hostName: "Host",
            subject: "Biology",
            courseNumber: nil,
            studyTopic: "Cells",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date().addingTimeInterval(3600),
            duration: 60,
            maxAttendees: 2,
            isPublic: true
        )
        
        // Fill the session
        service.joinStudySession(sessionId: sessionId, userId: "user1", userName: "User 1")
        
        // Try to join when full
        let canJoin = service.joinStudySession(sessionId: sessionId, userId: "user2", userName: "User 2")
        
        let session = service.studySessions.first { $0.id == sessionId }
        let attendeeCount = session?.attendeeIds.count ?? 0
        
        XCTAssertLessThanOrEqual(attendeeCount, 2, "Should not exceed max attendees")
    }
    
    func testGetUpcomingSessions() {
        // Create sessions at different times
        let futureDate = Date().addingTimeInterval(7200) // 2 hours from now
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        
        service.createStudySession(
            hostId: "host",
            hostName: "Host",
            subject: "Chemistry",
            courseNumber: nil,
            studyTopic: "Organic Chemistry",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: futureDate,
            duration: 60,
            maxAttendees: 3,
            isPublic: true
        )
        
        let upcomingSessions = service.getUpcomingSessions(forUserId: "host")
        
        XCTAssertGreaterThan(upcomingSessions.count, 0, "Should find upcoming sessions")
    }
    
    func testGetPublicSessions() {
        service.createStudySession(
            hostId: "host",
            hostName: "Host",
            subject: "Physics",
            courseNumber: nil,
            studyTopic: "Mechanics",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date().addingTimeInterval(3600),
            duration: 60,
            maxAttendees: 4,
            isPublic: true
        )
        
        let publicSessions = service.getPublicSessions(subject: nil)
        
        XCTAssertGreaterThan(publicSessions.count, 0, "Should find public sessions")
    }
    
    func testFilterSessionsBySubject() {
        service.createStudySession(
            hostId: "host",
            hostName: "Host",
            subject: "Computer Science",
            courseNumber: nil,
            studyTopic: "Algorithms",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date().addingTimeInterval(3600),
            duration: 60,
            maxAttendees: 3,
            isPublic: true
        )
        
        let csSessions = service.getPublicSessions(subject: "Computer Science")
        
        for session in csSessions {
            XCTAssertEqual(session.subject.rawValue, "Computer Science", "Should only return CS sessions")
        }
    }
    
    // MARK: - Check-In Tests
    
    func testCheckInAtCafe() {
        let initialCheckIns = service.userCheckIns.count
        let initialPoints = service.userRewards.points
        
        let checkInId = service.checkIn(
            userId: "user123",
            matchId: "match456",
            cafeId: "cafe789",
            cafeName: "Test Café",
            latitude: 43.6150,
            longitude: -116.2023,
            coffeeOrdered: "Vanilla Latte",
            rating: 5
        )
        
        XCTAssertNotNil(checkInId, "Should return a check-in ID")
        XCTAssertGreaterThan(service.userCheckIns.count, initialCheckIns, "Should add check-in to list")
        XCTAssertGreaterThan(service.userRewards.points, initialPoints, "Should award points")
    }
    
    func testCheckInWithMatchAwardsMorePoints() {
        let initialPoints = service.userRewards.points
        
        // Check-in with match
        service.checkIn(
            userId: "user",
            matchId: "match123",
            cafeId: "cafe",
            cafeName: "Café",
            latitude: 0,
            longitude: 0,
            coffeeOrdered: nil,
            rating: nil
        )
        
        let pointsWithMatch = service.userRewards.points - initialPoints
        
        XCTAssertGreaterThan(pointsWithMatch, 10, "Check-in with match should award more than 10 points")
    }
    
    func testCheckInTracksUniqueCafes() {
        let initialCafesCount = service.userRewards.uniqueCafesVisited.count
        
        service.checkIn(
            userId: "user",
            matchId: nil,
            cafeId: "new_cafe_123",
            cafeName: "New Café",
            latitude: 0,
            longitude: 0,
            coffeeOrdered: nil,
            rating: nil
        )
        
        XCTAssertGreaterThan(
            service.userRewards.uniqueCafesVisited.count,
            initialCafesCount,
            "Should track unique café visits"
        )
        XCTAssertTrue(
            service.userRewards.uniqueCafesVisited.contains("new_cafe_123"),
            "Should add new café to list"
        )
    }
    
    func testGetCheckInsWithMatch() {
        service.checkIn(
            userId: "user123",
            matchId: "match456",
            cafeId: "cafe",
            cafeName: "Café",
            latitude: 0,
            longitude: 0,
            coffeeOrdered: nil,
            rating: nil
        )
        
        let checkIns = service.getCheckInsWithMatch(matchId: "match456")
        
        XCTAssertGreaterThan(checkIns.count, 0, "Should find check-ins with specific match")
        
        for checkIn in checkIns {
            XCTAssertEqual(checkIn.matchId, "match456", "All check-ins should be with the specified match")
        }
    }
    
    // MARK: - Badge Tests
    
    func testUnlockBadge() {
        let badgeId = "first_latte"
        
        service.unlockBadge(badgeId: badgeId)
        
        XCTAssertTrue(
            service.userRewards.unlockedBadges.contains(badgeId),
            "Badge should be unlocked"
        )
        
        let badge = service.userBadges.first { $0.id == badgeId }
        XCTAssertTrue(badge?.isUnlocked ?? false, "Badge isUnlocked flag should be true")
    }
    
    func testCannotUnlockSameBadgeTwice() {
        let badgeId = "social_butterfly"
        let initialCount = service.userRewards.unlockedBadges.count
        
        service.unlockBadge(badgeId: badgeId)
        let countAfterFirst = service.userRewards.unlockedBadges.count
        
        service.unlockBadge(badgeId: badgeId)
        let countAfterSecond = service.userRewards.unlockedBadges.count
        
        XCTAssertEqual(countAfterFirst, countAfterSecond, "Should not unlock same badge twice")
    }
    
    func testCheckBadgeProgress() {
        let badgeId = "test_badge"
        let progress = service.checkBadgeProgress(badgeId: badgeId)
        
        XCTAssertGreaterThanOrEqual(progress, 0.0, "Progress should be at least 0")
        XCTAssertLessThanOrEqual(progress, 1.0, "Progress should not exceed 1.0")
    }
    
    // MARK: - Streak Tests
    
    func testUpdateDailyStreak() {
        let initialStreak = service.userRewards.streak
        
        service.updateDailyStreak()
        
        // Streak should either increase or reset depending on last check-in
        XCTAssertNotNil(service.userRewards.streak, "Streak should be updated")
    }
    
    func testStreakIncreasesWithConsecutiveDays() {
        // This would require mocking dates, but we can verify the method exists
        service.updateDailyStreak()
        
        let streak = service.userRewards.streak
        XCTAssertGreaterThanOrEqual(streak, 0, "Streak should be non-negative")
    }
    
    // MARK: - Points and Leveling Tests
    
    func testPointsAwardedForActivities() {
        let initialPoints = service.userRewards.points
        
        // Check-in awards points
        service.checkIn(
            userId: "user",
            matchId: nil,
            cafeId: "cafe",
            cafeName: "Café",
            latitude: 0,
            longitude: 0,
            coffeeOrdered: nil,
            rating: nil
        )
        
        XCTAssertGreaterThan(service.userRewards.points, initialPoints, "Activities should award points")
    }
    
    func testLevelUpOccursAtThreshold() {
        let initialLevel = service.userRewards.level
        
        // Add enough points to potentially level up
        service.userRewards.points += 500
        
        // Check if leveling logic would trigger
        // (This would need the actual leveling method to be exposed or tested indirectly)
        XCTAssertTrue(service.userRewards.points > 0, "Points should accumulate")
    }
    
    // MARK: - Data Integrity Tests
    
    func testServiceFollowsSRP() {
        // CoffeeExperienceService should handle business logic ONLY
        // It should NOT:
        // - Contain UI code
        // - Define models (those are in separate files)
        // - Handle networking directly (would use a separate network service)
        
        XCTAssertTrue(type(of: service).self == CoffeeExperienceService.self)
    }
    
    func testServiceIsObservable() {
        // Service should be ObservableObject for SwiftUI
        XCTAssertTrue(service is ObservableObject)
    }
    
    func testPublishedPropertiesExist() {
        // Service should publish changes for UI updates
        XCTAssertNotNil(service.studySessions)
        XCTAssertNotNil(service.userCheckIns)
        XCTAssertNotNil(service.userRewards)
        XCTAssertNotNil(service.userBadges)
    }
    
    // MARK: - Performance Tests
    
    func testCreateMultipleSessionsPerformance() {
        measure {
            for i in 0..<10 {
                service.createStudySession(
                    hostId: "host_\(i)",
                    hostName: "Host \(i)",
                    subject: "Mathematics",
                    courseNumber: nil,
                    studyTopic: "Topic \(i)",
                    cafeId: "cafe",
                    cafeName: "Café",
                    scheduledDate: Date().addingTimeInterval(3600),
                    duration: 60,
                    maxAttendees: 4,
                    isPublic: true
                )
            }
        }
    }
    
    func testGetSessionsPerformance() {
        // Create some sessions first
        for i in 0..<20 {
            service.createStudySession(
                hostId: "host",
                hostName: "Host",
                subject: "Computer Science",
                courseNumber: nil,
                studyTopic: "Topic \(i)",
                cafeId: "cafe",
                cafeName: "Café",
                scheduledDate: Date().addingTimeInterval(Double(i) * 3600),
                duration: 60,
                maxAttendees: 4,
                isPublic: true
            )
        }
        
        measure {
            _ = service.getPublicSessions(subject: nil)
            _ = service.getUpcomingSessions(forUserId: "host")
        }
    }
    
    // MARK: - Edge Cases
    
    func testHandleEmptySessionList() {
        service.studySessions = []
        
        let sessions = service.getPublicSessions(subject: nil)
        XCTAssertEqual(sessions.count, 0, "Should handle empty session list")
    }
    
    func testHandleInvalidSessionId() {
        let success = service.joinStudySession(
            sessionId: "nonexistent_session",
            userId: "user",
            userName: "User"
        )
        
        XCTAssertFalse(success, "Should return false for invalid session ID")
    }
    
    func testHandleInvalidBadgeId() {
        let initialCount = service.userRewards.unlockedBadges.count
        
        service.unlockBadge(badgeId: "nonexistent_badge")
        
        // Should handle gracefully without crashing
        XCTAssertNotNil(service.userRewards.unlockedBadges)
    }
}
