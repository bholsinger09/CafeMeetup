import Foundation

// MARK: - Main Goal Model
public struct StudyGoal: Identifiable, Codable, Equatable {
    public let id: String
    public var title: String // e.g., "Pass Calc Midterm 80%"
    public var description: String?
    public var category: GoalCategory
    public var targetDate: Date
    public var createdAt: Date
    public var updatedAt: Date
    
    // Progress tracking
    public var currentProgress: Int // 0-100 percentage
    public var targetValue: Int? // e.g., 80 for "80%"
    public var milestones: [StudyMilestone]
    public var completedMilestoneIds: Set<String> // Track which milestones are done
    
    // Status
    public var status: GoalStatus
    public var parentGoalId: String? // For sub-goals (e.g., final quiz is under "Pass Calc")
    public var linkedSessionIds: [String]? // Study sessions contributing to this goal
    
    // CloudKit sync
    public var isLocalOnly: Bool = false
    public var lastSyncedAt: Date?
    public var cloudKitRecordId: String?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String? = nil,
        category: GoalCategory,
        targetDate: Date,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        currentProgress: Int = 0,
        targetValue: Int? = nil,
        milestones: [StudyMilestone] = [],
        completedMilestoneIds: Set<String> = [],
        status: GoalStatus = .notStarted,
        parentGoalId: String? = nil,
        linkedSessionIds: [String]? = nil,
        isLocalOnly: Bool = false,
        lastSyncedAt: Date? = nil,
        cloudKitRecordId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.currentProgress = currentProgress
        self.targetValue = targetValue
        self.milestones = milestones
        self.completedMilestoneIds = completedMilestoneIds
        self.status = status
        self.parentGoalId = parentGoalId
        self.linkedSessionIds = linkedSessionIds
        self.isLocalOnly = isLocalOnly
        self.lastSyncedAt = lastSyncedAt
        self.cloudKitRecordId = cloudKitRecordId
    }
    
    // MARK: - Computed Properties
    
    var isOverdue: Bool {
        return targetDate < Date() && status != .completed && status != .abandoned
    }
    
    var daysRemaining: Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: targetDate)
        return components.day ?? 0
    }
    
    var progressPercentage: Double {
        return Double(currentProgress) / 100.0
    }
    
    var completedMilestoneCount: Int {
        return completedMilestoneIds.count
    }
    
    var totalMilestoneCount: Int {
        return milestones.count
    }
    
    var milestoneSummary: String {
        return "\(completedMilestoneCount) of \(totalMilestoneCount) milestones"
    }
    
    // Get next uncompleted milestone
    var nextMilestone: StudyMilestone? {
        return milestones.first { !completedMilestoneIds.contains($0.id) }
    }
}

// MARK: - Milestone Model
public struct StudyMilestone: Identifiable, Codable, Equatable {
    public let id: String
    public let goalId: String
    public var title: String // e.g., "Study 2 hours"
    public var description: String?
    public var dueDate: Date
    public var position: Int // Order in the roadmap (0, 1, 2...)
    public var isCompleted: Bool
    public var completedAt: Date?
    public var targetMetric: String? // e.g., "2 hours", "80%"
    
    public init(
        id: String = UUID().uuidString,
        goalId: String,
        title: String,
        description: String? = nil,
        dueDate: Date,
        position: Int,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        targetMetric: String? = nil
    ) {
        self.id = id
        self.goalId = goalId
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.position = position
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.targetMetric = targetMetric
    }
    
    var isOverdue: Bool {
        return dueDate < Date() && !isCompleted
    }
}

// MARK: - Goal Categories
public enum GoalCategory: String, Codable, CaseIterable {
    case academic = "Academic"
    case campus = "Campus Involvement"
    case social = "Social & Networking"
    case wellness = "Wellness"
    case skills = "Skills Development"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .academic: return "📚"
        case .campus: return "🎓"
        case .social: return "👥"
        case .wellness: return "💪"
        case .skills: return "🛠️"
        case .other: return "⭐"
        }
    }
    
    var color: String {
        switch self {
        case .academic: return "blue"
        case .campus: return "green"
        case .social: return "purple"
        case .wellness: return "red"
        case .skills: return "orange"
        case .other: return "gray"
        }
    }
}

// MARK: - Goal Status
public enum GoalStatus: String, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
    case paused = "Paused"
    
    var emoji: String {
        switch self {
        case .notStarted: return "🔴"
        case .inProgress: return "🟡"
        case .completed: return "🟢"
        case .abandoned: return "⚫"
        case .paused: return "⚪"
        }
    }
}

// MARK: - Roadmap Collection
public struct StudyRoadmap: Identifiable, Codable {
    public let id: String
    public let userId: String
    public var title: String // e.g., "Fall Semester Roadmap"
    public var goals: [StudyGoal]
    public var createdAt: Date
    public var updatedAt: Date
    public var isActive: Bool
    public var theme: RoadmapTheme
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        title: String = "My Study Roadmap",
        goals: [StudyGoal] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isActive: Bool = true,
        theme: RoadmapTheme = .default
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.goals = goals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
        self.theme = theme
    }
    
    var sortedGoals: [StudyGoal] {
        return goals.sorted { $0.targetDate < $1.targetDate }
    }
    
    var completedGoals: [StudyGoal] {
        return goals.filter { $0.status == .completed }
    }
    
    var inProgressGoals: [StudyGoal] {
        return goals.filter { $0.status == .inProgress }
    }
    
    var overallProgress: Double {
        guard !goals.isEmpty else { return 0 }
        let totalProgress = goals.reduce(0) { $0 + $1.currentProgress }
        return Double(totalProgress) / Double(goals.count * 100)
    }
}

// MARK: - Roadmap Themes
public enum RoadmapTheme: String, Codable, CaseIterable {
    case `default` = "Default"
    case mountain = "Mountain"
    case ocean = "Ocean"
    case forest = "Forest"
    case space = "Space"
    
    var carEmoji: String {
        switch self {
        case .default: return "🚗"
        case .mountain: return "🚙"
        case .ocean: return "🚤"
        case .forest: return "🦌"
        case .space: return "🚀"
        }
    }
    
    var backgroundColor: String {
        switch self {
        case .default: return "gray.50"
        case .mountain: return "gray.100"
        case .ocean: return "blue.50"
        case .forest: return "green.50"
        case .space: return "indigo.50"
        }
    }
}
