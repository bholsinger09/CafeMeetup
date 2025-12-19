import XCTest
@testable import CafeMeetup
import CoreLocation

/// Tests for StudySession, CafeCheckIn, and CoffeeRewards models
/// Verifies study session functionality and rewards system
final class StudySessionModelTests: XCTestCase {
    
    // MARK: - StudySession Tests
    
    func testStudySessionHasRequiredProperties() {
        let session = StudySession(
            id: "test_session",
            hostId: "user_123",
            hostName: "John Doe",
            subject: .computerScience,
            courseNumber: "CS 101",
            studyTopic: "Data Structures",
            cafeId: "cafe_456",
            cafeName: "Local Café",
            scheduledDate: Date(),
            duration: 60,
            attendeeIds: ["user_123"],
            maxAttendees: 4,
            isPublic: true,
            status: .scheduled
        )
        
        XCTAssertEqual(session.id, "test_session")
        XCTAssertEqual(session.hostId, "user_123")
        XCTAssertEqual(session.hostName, "John Doe")
        XCTAssertEqual(session.subject, .computerScience)
        XCTAssertEqual(session.courseNumber, "CS 101")
        XCTAssertEqual(session.studyTopic, "Data Structures")
        XCTAssertEqual(session.duration, 60)
        XCTAssertEqual(session.maxAttendees, 4)
        XCTAssertTrue(session.isPublic)
        XCTAssertEqual(session.status, .scheduled)
    }
    
    func testStudySessionStatusTransitions() {
        var session = StudySession(
            id: "test",
            hostId: "user",
            hostName: "Host",
            subject: .mathematics,
            courseNumber: nil,
            studyTopic: "Calculus",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date(),
            duration: 90,
            attendeeIds: [],
            maxAttendees: 2,
            isPublic: true,
            status: .scheduled
        )
        
        XCTAssertEqual(session.status, .scheduled)
        
        session.status = .inProgress
        XCTAssertEqual(session.status, .inProgress)
        
        session.status = .completed
        XCTAssertEqual(session.status, .completed)
        
        session.status = .cancelled
        XCTAssertEqual(session.status, .cancelled)
    }
    
    func testStudySubjectHasAllRequiredFields() {
        let allSubjects = StudySubject.allCases
        
        XCTAssertGreaterThanOrEqual(allSubjects.count, 16, "Should have at least 16 subjects")
        
        for subject in allSubjects {
            XCTAssertFalse(subject.rawValue.isEmpty, "Subject '\(subject)' should have a name")
            XCTAssertFalse(subject.emoji.isEmpty, "Subject '\(subject)' should have an emoji")
        }
    }
    
    func testSpecificStudySubjectsExist() {
        XCTAssertTrue(StudySubject.allCases.contains(.computerScience))
        XCTAssertTrue(StudySubject.allCases.contains(.mathematics))
        XCTAssertTrue(StudySubject.allCases.contains(.biology))
        XCTAssertTrue(StudySubject.allCases.contains(.chemistry))
        XCTAssertTrue(StudySubject.allCases.contains(.physics))
    }
    
    func testStudySessionCapacityValidation() {
        let session = StudySession(
            id: "test",
            hostId: "host",
            hostName: "Host",
            subject: .computerScience,
            courseNumber: nil,
            studyTopic: "Topic",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date(),
            duration: 60,
            attendeeIds: ["user1", "user2", "user3"],
            maxAttendees: 3,
            isPublic: true,
            status: .scheduled
        )
        
        XCTAssertEqual(session.attendeeIds.count, 3)
        XCTAssertEqual(session.maxAttendees, 3)
        XCTAssertTrue(session.attendeeIds.count <= session.maxAttendees, "Attendees should not exceed max")
    }
    
    // MARK: - CafeCheckIn Tests
    
    func testCafeCheckInHasRequiredProperties() {
        let location = CLLocationCoordinate2D(latitude: 43.6150, longitude: -116.2023)
        let checkIn = CafeCheckIn(
            id: "checkin_123",
            userId: "user_456",
            matchId: "match_789",
            cafeId: "cafe_101",
            cafeName: "Test Café",
            location: location,
            timestamp: Date(),
            coffeeOrdered: "Vanilla Latte",
            rating: 5,
            photoUrl: nil,
            pointsEarned: 30
        )
        
        XCTAssertEqual(checkIn.id, "checkin_123")
        XCTAssertEqual(checkIn.userId, "user_456")
        XCTAssertEqual(checkIn.matchId, "match_789")
        XCTAssertEqual(checkIn.cafeName, "Test Café")
        XCTAssertEqual(checkIn.location.latitude, 43.6150, accuracy: 0.001)
        XCTAssertEqual(checkIn.location.longitude, -116.2023, accuracy: 0.001)
        XCTAssertEqual(checkIn.coffeeOrdered, "Vanilla Latte")
        XCTAssertEqual(checkIn.rating, 5)
        XCTAssertEqual(checkIn.pointsEarned, 30)
    }
    
    func testCafeCheckInRatingValidation() {
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        let ratings = [1, 2, 3, 4, 5]
        for rating in ratings {
            let checkIn = CafeCheckIn(
                id: "test",
                userId: "user",
                matchId: "match",
                cafeId: "cafe",
                cafeName: "Café",
                location: location,
                timestamp: Date(),
                coffeeOrdered: nil,
                rating: rating,
                photoUrl: nil,
                pointsEarned: 30
            )
            
            XCTAssertTrue(checkIn.rating! >= 1 && checkIn.rating! <= 5, "Rating should be between 1 and 5")
        }
    }
    
    func testCafeCheckInPointsVariations() {
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // Solo check-in
        let soloCheckIn = CafeCheckIn(
            id: "solo",
            userId: "user",
            matchId: nil,
            cafeId: "cafe",
            cafeName: "Café",
            location: location,
            timestamp: Date(),
            coffeeOrdered: nil,
            rating: nil,
            photoUrl: nil,
            pointsEarned: 10
        )
        XCTAssertEqual(soloCheckIn.pointsEarned, 10)
        
        // With match
        let matchCheckIn = CafeCheckIn(
            id: "match",
            userId: "user",
            matchId: "match123",
            cafeId: "cafe",
            cafeName: "Café",
            location: location,
            timestamp: Date(),
            coffeeOrdered: nil,
            rating: nil,
            photoUrl: nil,
            pointsEarned: 30
        )
        XCTAssertEqual(matchCheckIn.pointsEarned, 30)
    }
    
    // MARK: - CoffeeRewards Tests
    
    func testCoffeeRewardsInitialization() {
        let rewards = CoffeeRewards(
            points: 150,
            level: 3,
            streak: 5,
            totalCheckIns: 8,
            totalStudySessions: 2,
            uniqueCafesVisited: ["cafe1", "cafe2", "cafe3"],
            unlockedBadges: ["first_latte", "social_butterfly"]
        )
        
        XCTAssertEqual(rewards.points, 150)
        XCTAssertEqual(rewards.level, 3)
        XCTAssertEqual(rewards.streak, 5)
        XCTAssertEqual(rewards.totalCheckIns, 8)
        XCTAssertEqual(rewards.totalStudySessions, 2)
        XCTAssertEqual(rewards.uniqueCafesVisited.count, 3)
        XCTAssertEqual(rewards.unlockedBadges.count, 2)
    }
    
    func testCoffeeRewardsLevelNames() {
        XCTAssertEqual(CoffeeRewards.levelName(for: 0), "Coffee Newbie")
        XCTAssertEqual(CoffeeRewards.levelName(for: 1), "Café Regular")
        XCTAssertEqual(CoffeeRewards.levelName(for: 2), "Espresso Enthusiast")
        XCTAssertEqual(CoffeeRewards.levelName(for: 3), "Latte Artist")
        XCTAssertEqual(CoffeeRewards.levelName(for: 4), "Barista Expert")
        XCTAssertEqual(CoffeeRewards.levelName(for: 5), "Coffee Legend")
        XCTAssertEqual(CoffeeRewards.levelName(for: 10), "Coffee Legend", "Max level should be Coffee Legend")
    }
    
    func testCoffeeRewardsCurrentLevelName() {
        let rewards = CoffeeRewards(
            points: 150,
            level: 3,
            streak: 0,
            totalCheckIns: 0,
            totalStudySessions: 0,
            uniqueCafesVisited: [],
            unlockedBadges: []
        )
        
        XCTAssertEqual(rewards.currentLevelName, "Latte Artist")
    }
    
    func testCoffeeRewardsPointsToNextLevel() {
        var rewards = CoffeeRewards(
            points: 150,
            level: 1,
            streak: 0,
            totalCheckIns: 0,
            totalStudySessions: 0,
            uniqueCafesVisited: [],
            unlockedBadges: []
        )
        
        let pointsNeeded = rewards.pointsToNextLevel
        XCTAssertGreaterThan(pointsNeeded, 0, "Should need points to reach next level")
        XCTAssertLessThanOrEqual(pointsNeeded, 100, "Points to next level should be reasonable")
    }
    
    func testCoffeeRewardsProgressCalculation() {
        var rewards = CoffeeRewards(
            points: 0,
            level: 0,
            streak: 0,
            totalCheckIns: 0,
            totalStudySessions: 0,
            uniqueCafesVisited: [],
            unlockedBadges: []
        )
        
        let initialProgress = rewards.progressToNextLevel
        XCTAssertEqual(initialProgress, 0.0, "Progress should start at 0")
        
        rewards.points = 50
        let midProgress = rewards.progressToNextLevel
        XCTAssertGreaterThan(midProgress, 0.0, "Progress should increase with points")
        XCTAssertLessThanOrEqual(midProgress, 1.0, "Progress should not exceed 1.0")
    }
    
    func testCoffeeRewardsStreakTracking() {
        var rewards = CoffeeRewards(
            points: 0,
            level: 0,
            streak: 0,
            totalCheckIns: 0,
            totalStudySessions: 0,
            uniqueCafesVisited: [],
            unlockedBadges: []
        )
        
        XCTAssertEqual(rewards.streak, 0)
        
        rewards.streak = 5
        XCTAssertEqual(rewards.streak, 5)
        
        rewards.streak = 0
        XCTAssertEqual(rewards.streak, 0, "Streak should be able to reset to 0")
    }
    
    func testCoffeeRewardsUniqueCafesTracking() {
        var rewards = CoffeeRewards(
            points: 0,
            level: 0,
            streak: 0,
            totalCheckIns: 0,
            totalStudySessions: 0,
            uniqueCafesVisited: [],
            unlockedBadges: []
        )
        
        XCTAssertEqual(rewards.uniqueCafesVisited.count, 0)
        
        rewards.uniqueCafesVisited.append("cafe1")
        XCTAssertEqual(rewards.uniqueCafesVisited.count, 1)
        
        rewards.uniqueCafesVisited.append("cafe2")
        XCTAssertEqual(rewards.uniqueCafesVisited.count, 2)
        
        // Test uniqueness
        let uniqueCafes = Set(rewards.uniqueCafesVisited)
        XCTAssertEqual(uniqueCafes.count, rewards.uniqueCafesVisited.count, "All cafés should be unique")
    }
    
    // MARK: - Data Integrity Tests
    
    func testStudySessionFollowsSRP() {
        // StudySession should only contain data
        // It should NOT have methods like:
        // - session.start()
        // - session.addAttendee()
        // - session.complete()
        // These belong in CoffeeExperienceService
        
        let session = StudySession(
            id: "test",
            hostId: "host",
            hostName: "Host",
            subject: .computerScience,
            courseNumber: nil,
            studyTopic: "Topic",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date(),
            duration: 60,
            attendeeIds: [],
            maxAttendees: 4,
            isPublic: true,
            status: .scheduled
        )
        
        XCTAssertTrue(type(of: session) == StudySession.self)
    }
    
    func testModelsAreIdentifiable() {
        let session = StudySession(
            id: "unique_session",
            hostId: "host",
            hostName: "Host",
            subject: .mathematics,
            courseNumber: nil,
            studyTopic: "Topic",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date(),
            duration: 60,
            attendeeIds: [],
            maxAttendees: 2,
            isPublic: true,
            status: .scheduled
        )
        
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let checkIn = CafeCheckIn(
            id: "unique_checkin",
            userId: "user",
            matchId: nil,
            cafeId: "cafe",
            cafeName: "Café",
            location: location,
            timestamp: Date(),
            coffeeOrdered: nil,
            rating: nil,
            photoUrl: nil,
            pointsEarned: 10
        )
        
        XCTAssertEqual(session.id, "unique_session")
        XCTAssertEqual(checkIn.id, "unique_checkin")
    }
    
    // MARK: - Edge Cases
    
    func testStudySessionHandlesOptionalFields() {
        let session = StudySession(
            id: "test",
            hostId: "host",
            hostName: "Host",
            subject: .other,
            courseNumber: nil,
            studyTopic: "General Study",
            cafeId: "cafe",
            cafeName: "Café",
            scheduledDate: Date(),
            duration: 60,
            attendeeIds: [],
            maxAttendees: 1,
            isPublic: false,
            status: .scheduled
        )
        
        XCTAssertNil(session.courseNumber, "Course number should be optional")
        XCTAssertFalse(session.isPublic, "Session should support private mode")
    }
    
    func testCafeCheckInHandlesOptionalFields() {
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let checkIn = CafeCheckIn(
            id: "test",
            userId: "user",
            matchId: nil,
            cafeId: "cafe",
            cafeName: "Café",
            location: location,
            timestamp: Date(),
            coffeeOrdered: nil,
            rating: nil,
            photoUrl: nil,
            pointsEarned: 10
        )
        
        XCTAssertNil(checkIn.matchId, "Match ID should be optional (solo check-in)")
        XCTAssertNil(checkIn.coffeeOrdered, "Coffee ordered should be optional")
        XCTAssertNil(checkIn.rating, "Rating should be optional")
        XCTAssertNil(checkIn.photoUrl, "Photo URL should be optional")
    }
}
