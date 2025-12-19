import Foundation

/// Academic Achievement Badges - Emphasizes academic collaboration
/// Users earn badges for study sessions, tutoring, and academic progress
extension CoffeeBadgeSystem {
    static let academicBadges: [CoffeeBadge] = [
        // Study Session Badges
        CoffeeBadge(
            id: "first_study_session",
            name: "First Study Session",
            description: "Complete your first group study session",
            emoji: "📚",
            rarity: .common,
            unlockCriteria: "Complete 1 study session"
        ),
        CoffeeBadge(
            id: "study_group_organizer",
            name: "Study Group Organizer",
            description: "Host 5 study sessions",
            emoji: "👨‍🏫",
            rarity: .rare,
            unlockCriteria: "Host 5 group study sessions"
        ),
        CoffeeBadge(
            id: "dedicated_student",
            name: "Dedicated Student",
            description: "Study for 15 hours in one week",
            emoji: "⭐️",
            rarity: .rare,
            unlockCriteria: "Study 15 hours in a week"
        ),
        CoffeeBadge(
            id: "study_master",
            name: "Study Master",
            description: "Complete 25 study sessions",
            emoji: "🏆",
            rarity: .epic,
            unlockCriteria: "Complete 25 total study sessions"
        ),
        
        // Tutoring Badges
        CoffeeBadge(
            id: "helpful_tutor",
            name: "Helpful Tutor",
            description: "Help other students in 5 study sessions",
            emoji: "🎓",
            rarity: .rare,
            unlockCriteria: "Be designated as tutor/helper in 5 sessions"
        ),
        CoffeeBadge(
            id: "subject_expert",
            name: "Subject Expert",
            description: "Tutor students in 3 different subjects",
            emoji: "🧠",
            rarity: .epic,
            unlockCriteria: "Tutor in 3 different course subjects"
        ),
        CoffeeBadge(
            id: "teaching_legend",
            name: "Teaching Legend",
            description: "Help 20 different students",
            emoji: "👑",
            rarity: .legendary,
            unlockCriteria: "Study with 20 unique students"
        ),
        
        // Streak Badges
        CoffeeBadge(
            id: "week_warrior",
            name: "Week Warrior",
            description: "Study 7 days in a row",
            emoji: "🔥",
            rarity: .rare,
            unlockCriteria: "7-day study streak"
        ),
        CoffeeBadge(
            id: "month_champion",
            name: "Month Champion",
            description: "Study 30 days in a row",
            emoji: "💪",
            rarity: .epic,
            unlockCriteria: "30-day study streak"
        ),
        CoffeeBadge(
            id: "unstoppable",
            name: "Unstoppable",
            description: "Study 60 days in a row",
            emoji: "🚀",
            rarity: .legendary,
            unlockCriteria: "60-day study streak"
        ),
        
        // Course Coverage Badges
        CoffeeBadge(
            id: "multidisciplinary",
            name: "Multidisciplinary",
            description: "Study 5 different courses",
            emoji: "🎨",
            rarity: .rare,
            unlockCriteria: "Attend study sessions for 5 courses"
        ),
        CoffeeBadge(
            id: "course_champion",
            name: "Course Champion",
            description: "Attend 10 sessions for one course",
            emoji: "🏅",
            rarity: .epic,
            unlockCriteria: "10 sessions in same course"
        ),
        
        // Group Collaboration Badges
        CoffeeBadge(
            id: "team_player",
            name: "Team Player",
            description: "Join 10 group study sessions",
            emoji: "🤝",
            rarity: .common,
            unlockCriteria: "Join 10 group sessions (3+ people)"
        ),
        CoffeeBadge(
            id: "collaboration_expert",
            name: "Collaboration Expert",
            description: "Study with 15 different students",
            emoji: "👥",
            rarity: .rare,
            unlockCriteria: "Study with 15 unique students"
        ),
        
        // Location Badges
        CoffeeBadge(
            id: "cafe_scholar",
            name: "Café Scholar",
            description: "Study at 10 different coffee shops",
            emoji: "☕️",
            rarity: .rare,
            unlockCriteria: "Study at 10 unique cafés"
        ),
        CoffeeBadge(
            id: "location_explorer",
            name: "Location Explorer",
            description: "Study at 20 different coffee shops",
            emoji: "🗺️",
            rarity: .epic,
            unlockCriteria: "Study at 20 unique cafés"
        ),
        
        // Time Investment Badges
        CoffeeBadge(
            id: "hundred_hours",
            name: "100 Hour Club",
            description: "Study for 100 total hours",
            emoji: "💯",
            rarity: .epic,
            unlockCriteria: "Accumulate 100 study hours"
        ),
        CoffeeBadge(
            id: "marathon_studier",
            name: "Marathon Studier",
            description: "Complete a 6+ hour study session",
            emoji: "⏰",
            rarity: .rare,
            unlockCriteria: "Attend one 6-hour session"
        ),
        
        // Early Adopter / Community Badges
        CoffeeBadge(
            id: "early_adopter",
            name: "Early Adopter",
            description: "One of the first to use StudyBrew",
            emoji: "🌟",
            rarity: .legendary,
            unlockCriteria: "Join in first month of launch"
        ),
        CoffeeBadge(
            id: "community_builder",
            name: "Community Builder",
            description: "Help grow the study community",
            emoji: "🏗️",
            rarity: .epic,
            unlockCriteria: "Refer 5 students to StudyBrew"
        )
    ]
    
    // Combined badge list including both original and academic badges
    static var allBadgesWithAcademic: [CoffeeBadge] {
        return allBadges + academicBadges
    }
}

/// User badge profile - displayed on profile to show academic achievements
struct AcademicProfile {
    var isTutor: Bool
    var tutorSubjects: [String]
    var totalStudyHours: Int
    var studyStreak: Int
    var unlockedBadges: [String] // Badge IDs
    
    // Get displayable tutor badge
    var tutorBadge: String? {
        guard isTutor, !tutorSubjects.isEmpty else { return nil }
        return "🎓 Tutor"
    }
    
    // Get displayable study leader badge
    var studyLeaderBadge: String? {
        guard totalStudyHours >= 50 else { return nil }
        return "👨‍🏫 Study Leader"
    }
    
    // Get displayable streak badge
    var streakBadge: String? {
        guard studyStreak >= 7 else { return nil }
        return "🔥 \(studyStreak) Day Streak"
    }
    
    // All displayable badges for profile
    var displayBadges: [String] {
        var badges: [String] = []
        
        if let tutor = tutorBadge { badges.append(tutor) }
        if let leader = studyLeaderBadge { badges.append(leader) }
        if let streak = streakBadge { badges.append(streak) }
        
        return badges
    }
}
