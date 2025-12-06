import Foundation
import Combine
import CoreLocation

/// Service to manage unique LatteLink features: study sessions, check-ins, and rewards
@MainActor
class CoffeeExperienceService: ObservableObject {
    static let shared = CoffeeExperienceService()
    
    @Published var studySessions: [StudySession] = []
    @Published var userCheckIns: [CafeCheckIn] = []
    @Published var userRewards = CoffeeRewards(
        points: 0,
        level: 0,
        streak: 0,
        totalCheckIns: 0,
        totalStudySessions: 0,
        uniqueCafesVisited: [],
        unlockedBadges: []
    )
    @Published var userBadges: [CoffeeBadge] = CoffeeBadgeSystem.allBadges
    
    nonisolated private init() {
        // Note: Cannot call loadMockData() here as it's @MainActor isolated
        // Mock data will be loaded on first access
    }
    
    // Lazy initialization flag
    private var isInitialized = false
    
    private func ensureInitialized() {
        guard !isInitialized else { return }
        isInitialized = true
        loadMockData()
    }
    
    // MARK: - Study Sessions
    
    func createStudySession(
        hostId: String,
        hostName: String,
        subject: String,
        courseNumber: String?,
        studyTopic: String,
        cafeId: String,
        cafeName: String,
        scheduledDate: Date,
        duration: Int,
        maxAttendees: Int,
        isPublic: Bool
    ) async throws {
        ensureInitialized()
        let session = StudySession(
            id: UUID().uuidString,
            hostId: hostId,
            hostName: hostName,
            subject: subject,
            courseNumber: courseNumber,
            studyTopic: studyTopic,
            cafeId: cafeId,
            cafeName: cafeName,
            scheduledDate: scheduledDate,
            duration: duration,
            attendeeIds: [hostId],
            maxAttendees: maxAttendees,
            isPublic: isPublic,
            status: .scheduled,
            createdAt: Date()
        )
        
        await MainActor.run {
            studySessions.append(session)
            userRewards.addPoints(20) // Reward for creating session
        }
    }
    
    func joinStudySession(_ sessionId: String, userId: String) async throws {
        guard let index = studySessions.firstIndex(where: { $0.id == sessionId }) else {
            throw CoffeeExperienceError.sessionNotFound
        }
        
        await MainActor.run {
            if !studySessions[index].attendeeIds.contains(userId) {
                studySessions[index].attendeeIds.append(userId)
                userRewards.addPoints(15) // Reward for joining
            }
        }
    }
    
    func getUpcomingSessions(forUserId userId: String) -> [StudySession] {
        studySessions.filter { session in
            session.isUpcoming &&
            (session.isPublic || session.attendeeIds.contains(userId))
        }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    func getPublicSessions(subject: String? = nil) -> [StudySession] {
        var sessions = studySessions.filter { $0.isPublic && $0.isUpcoming && !$0.isFull }
        
        if let subject = subject {
            sessions = sessions.filter { $0.subject == subject }
        }
        
        return sessions.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    // MARK: - Café Check-ins
    
    func checkIn(
        userId: String,
        cafeId: String,
        cafeName: String,
        location: CLLocationCoordinate2D,
        matchId: String? = nil,
        studySessionId: String? = nil,
        coffeeOrdered: String? = nil
    ) async throws {
        let checkIn = CafeCheckIn(
            id: UUID().uuidString,
            userId: userId,
            cafeId: cafeId,
            cafeName: cafeName,
            location: location,
            timestamp: Date(),
            matchId: matchId,
            studySessionId: studySessionId,
            coffeeOrdered: coffeeOrdered
        )
        
        await MainActor.run {
            userCheckIns.append(checkIn)
            userRewards.totalCheckIns += 1
            userRewards.uniqueCafesVisited.insert(cafeId)
            
            // Award points based on check-in type
            if matchId != nil {
                userRewards.addPoints(30) // Date check-in worth more
            } else {
                userRewards.addPoints(10) // Solo check-in
            }
            
            if studySessionId != nil {
                userRewards.totalStudySessions += 1
                userRewards.addPoints(25) // Study session check-in
            }
            
            // Check for badge unlocks
            checkBadgeProgress()
        }
    }
    
    func getCheckInHistory(forUserId userId: String) -> [CafeCheckIn] {
        userCheckIns
            .filter { $0.userId == userId }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    func getCheckInsWithMatch(_ matchId: String) -> [CafeCheckIn] {
        userCheckIns.filter { $0.matchId == matchId }
    }
    
    // MARK: - Badges & Rewards
    
    private func checkBadgeProgress() {
        // First Latte
        if userRewards.totalCheckIns >= 1 {
            unlockBadge("first_latte")
        }
        
        // Barista Basics
        if userRewards.uniqueCafesVisited.count >= 5 {
            unlockBadge("barista_basics")
        }
        
        // Coffee Connoisseur
        if userRewards.uniqueCafesVisited.count >= 15 {
            unlockBadge("coffee_connoisseur")
        }
        
        // Study Buddy
        if userRewards.totalStudySessions >= 3 {
            unlockBadge("study_buddy")
        }
        
        // Coffee Date Pro
        let dateCheckIns = userCheckIns.filter { $0.matchId != nil }
        if dateCheckIns.count >= 10 {
            unlockBadge("coffee_date_pro")
        }
        
        // Social Butterfly
        // This would check actual match count from MatchService
        
        // Latte Legend
        if userRewards.streak >= 30 {
            unlockBadge("latte_legend")
        }
    }
    
    private func unlockBadge(_ badgeId: String) {
        guard !userRewards.unlockedBadges.contains(badgeId) else { return }
        
        if let index = userBadges.firstIndex(where: { $0.id == badgeId }) {
            userBadges[index].isUnlocked = true
            userBadges[index].unlockedDate = Date()
            userRewards.unlockedBadges.append(badgeId)
            
            // Award points based on rarity
            let badge = userBadges[index]
            switch badge.rarity {
            case .common: userRewards.addPoints(50)
            case .rare: userRewards.addPoints(100)
            case .epic: userRewards.addPoints(250)
            case .legendary: userRewards.addPoints(500)
            }
        }
    }
    
    func getUnlockedBadges() -> [CoffeeBadge] {
        userBadges.filter { $0.isUnlocked }
    }
    
    func getLockedBadges() -> [CoffeeBadge] {
        userBadges.filter { !$0.isUnlocked }
    }
    
    // MARK: - Streak Management
    
    func updateDailyStreak() {
        let lastActivity = userCheckIns.last?.timestamp ?? Date.distantPast
        let daysSinceLastActivity = Calendar.current.dateComponents([.day], from: lastActivity, to: Date()).day ?? 0
        
        if daysSinceLastActivity == 1 {
            userRewards.streak += 1
            userRewards.addPoints(5 * userRewards.streak) // Bonus multiplier
        } else if daysSinceLastActivity > 1 {
            userRewards.streak = 1 // Reset streak
        }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        // Sample study sessions
        let session1 = StudySession(
            id: "session1",
            hostId: "user1",
            hostName: "Sarah",
            subject: "Computer Science",
            courseNumber: "CS 101",
            studyTopic: "Data Structures & Algorithms",
            cafeId: "cafe1",
            cafeName: "The Human Bean",
            scheduledDate: Date().addingTimeInterval(86400), // Tomorrow
            duration: 120,
            attendeeIds: ["user1"],
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
