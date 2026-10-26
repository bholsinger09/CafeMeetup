import Foundation
import Combine
import CoreData

@MainActor
public class StudyRoadmapViewModel: ObservableObject {
    @Published public var roadmap: StudyRoadmap
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var selectedGoal: StudyGoal?
    @Published public var showCreateGoal = false
    @Published public var showMilestoneDetail = false
    @Published public var syncStatus: SyncStatus = .idle
    
    public let userId: String
    private let roadmapService: StudyRoadmapService
    private let cloudKitService: CloudKitRoadmapService
    private var syncTimer: Timer?
    
    public init(userId: String) {
        self.userId = userId
        self.roadmapService = StudyRoadmapService(userId: userId)
        self.cloudKitService = CloudKitRoadmapService()
        self.roadmap = StudyRoadmap(userId: userId)
        
        loadRoadmapData()
        startAutoSync()
    }
    
    // MARK: - Load Data
    
    private func loadRoadmapData() {
        Task {
            self.isLoading = true
            print("[StudyRoadmapViewModel] 📂 Loading roadmap data...")
            print("[StudyRoadmapViewModel]    UserId: \(userId)")
            
            do {
                // First, try to load from local storage
                print("[StudyRoadmapViewModel]    Loading from local storage...")
                if let localRoadmap = roadmapService.loadLocalRoadmap() {
                    self.roadmap = localRoadmap
                    print("[StudyRoadmapViewModel] ✓ Loaded \(localRoadmap.goals.count) goals from local storage")
                } else {
                    print("[StudyRoadmapViewModel] ℹ️ No local roadmap found")
                }
                
                // Then sync with CloudKit if available
                print("[StudyRoadmapViewModel]    Checking CloudKit availability...")
                if await cloudKitService.isCloudKitAvailable() {
                    print("[StudyRoadmapViewModel] ✓ CloudKit is available, fetching from cloud...")
                    self.syncStatus = .syncing
                    let cloudRoadmap = try await cloudKitService.fetchRoadmap(userId: userId)
                    print("[StudyRoadmapViewModel] ✓ Fetched cloud roadmap with \(cloudRoadmap.goals.count) goals")
                    self.roadmap = mergeRoadmaps(local: self.roadmap, cloud: cloudRoadmap)
                    print("[StudyRoadmapViewModel] ✅ Roadmap loaded and merged!")
                    self.syncStatus = .synced
                } else {
                    print("[StudyRoadmapViewModel] ⚠️ CloudKit not available - using local only")
                    self.syncStatus = .failed
                }
            } catch {
                print("[StudyRoadmapViewModel] ❌ Error loading roadmap:")
                print("[StudyRoadmapViewModel]    \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.syncStatus = .failed
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Goal Management
    
    public func createGoal(
        title: String,
        description: String?,
        category: GoalCategory,
        targetDate: Date,
        milestones: [StudyMilestone] = []
    ) {
        let goal = StudyGoal(
            title: title,
            description: description,
            category: category,
            targetDate: targetDate,
            milestones: milestones,
            status: .notStarted
        )
        
        roadmap.goals.append(goal)
        roadmap.updatedAt = Date()
        
        // Save locally first
        roadmapService.saveLocalRoadmap(roadmap)
        
        // Then sync to CloudKit
        syncGoalToCloud(goal)
    }
    
    public func updateGoal(_ goal: StudyGoal) {
        if let index = roadmap.goals.firstIndex(where: { $0.id == goal.id }) {
            roadmap.goals[index] = goal
            roadmap.updatedAt = Date()
            
            roadmapService.saveLocalRoadmap(roadmap)
            syncGoalToCloud(goal)
        }
    }
    
    public func deleteGoal(_ goal: StudyGoal) {
        roadmap.goals.removeAll { $0.id == goal.id }
        roadmap.updatedAt = Date()
        
        roadmapService.saveLocalRoadmap(roadmap)
        
        Task {
            try await cloudKitService.deleteGoal(goal)
        }
    }
    
    public func updateGoalProgress(_ goalId: String, progress: Int) {
        if let index = roadmap.goals.firstIndex(where: { $0.id == goalId }) {
            roadmap.goals[index].currentProgress = min(100, max(0, progress))
            roadmap.goals[index].updatedAt = Date()
            
            // Auto-update status
            if progress == 0 {
                roadmap.goals[index].status = .notStarted
            } else if progress < 100 {
                roadmap.goals[index].status = .inProgress
            } else if progress == 100 {
                roadmap.goals[index].status = .completed
            }
            
            roadmapService.saveLocalRoadmap(roadmap)
            syncGoalToCloud(roadmap.goals[index])
        }
    }
    
    // MARK: - Milestone Management
    
    public func completeMilestone(_ milestone: StudyMilestone) {
        if let goalIndex = roadmap.goals.firstIndex(where: { $0.id == milestone.goalId }) {
            var updatedMilestone = milestone
            updatedMilestone.isCompleted = true
            updatedMilestone.completedAt = Date()
            
            roadmap.goals[goalIndex].completedMilestoneIds.insert(milestone.id)
            
            // Update milestone in the goal
            if let milestoneIndex = roadmap.goals[goalIndex].milestones.firstIndex(where: { $0.id == milestone.id }) {
                roadmap.goals[goalIndex].milestones[milestoneIndex] = updatedMilestone
            }
            
            // Auto-update goal progress based on milestones
            let completionPercentage = (Double(roadmap.goals[goalIndex].completedMilestoneIds.count) /
                                       Double(roadmap.goals[goalIndex].milestones.count)) * 100
            roadmap.goals[goalIndex].currentProgress = Int(completionPercentage)
            roadmap.goals[goalIndex].updatedAt = Date()
            
            roadmapService.saveLocalRoadmap(roadmap)
            syncGoalToCloud(roadmap.goals[goalIndex])
        }
    }
    
    public func addMilestoneToGoal(_ goalId: String, milestone: StudyMilestone) {
        if let index = roadmap.goals.firstIndex(where: { $0.id == goalId }) {
            roadmap.goals[index].milestones.append(milestone)
            roadmap.goals[index].updatedAt = Date()
            
            roadmapService.saveLocalRoadmap(roadmap)
            syncGoalToCloud(roadmap.goals[index])
        }
    }
    
    // MARK: - Statistics & Progress
    
    public var overallProgress: Double {
        return roadmap.overallProgress
    }
    
    public var completedGoalCount: Int {
        return roadmap.completedGoals.count
    }
    
    public var inProgressGoalCount: Int {
        return roadmap.inProgressGoals.count
    }
    
    public var totalGoalCount: Int {
        return roadmap.goals.count
    }
    
    public var carPositionProgress: Double {
        guard !roadmap.sortedGoals.isEmpty else { return 0 }
        
        // Calculate car position based on overall progress
        let avgProgress = roadmap.goals.reduce(0) { $0 + $1.currentProgress } / max(1, roadmap.goals.count)
        return Double(avgProgress) / 100.0
    }
    
    // Get the next active goal for the car to head towards
    public var nextGoal: StudyGoal? {
        return roadmap.sortedGoals.first { $0.status != .completed && $0.status != .abandoned }
    }
    
    // MARK: - CloudKit Sync
    
    private func syncGoalToCloud(_ goal: StudyGoal) {
        Task {
            print("[StudyRoadmapViewModel] 🔄 Attempting to sync goal: \(goal.title)")
            
            let isAvailable = await cloudKitService.isCloudKitAvailable()
            print("[StudyRoadmapViewModel]    CloudKit available: \(isAvailable)")
            
            if isAvailable {
                do {
                    print("[StudyRoadmapViewModel]    Starting sync...")
                    self.syncStatus = .syncing
                    try await cloudKitService.saveGoal(goal, userId: userId)
                    print("[StudyRoadmapViewModel] ✅ Sync successful!")
                    self.syncStatus = .synced
                } catch {
                    print("[StudyRoadmapViewModel] ❌ Sync failed!")
                    print("[StudyRoadmapViewModel]    Error: \(error.localizedDescription)")
                    print("[StudyRoadmapViewModel]    Domain: \((error as NSError).domain)")
                    print("[StudyRoadmapViewModel]    Code: \((error as NSError).code)")
                    
                    self.syncStatus = .failed
                    self.errorMessage = "Failed to sync goal: \(error.localizedDescription)"
                }
            } else {
                print("[StudyRoadmapViewModel] ⚠️ CloudKit not available, saving locally only")
                self.syncStatus = .failed
                self.errorMessage = "CloudKit not available - goal saved locally"
            }
        }
    }
    
    private func startAutoSync() {
        // Auto-sync every 5 minutes if connected
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task {
                await self?.loadRoadmapData()
            }
        }
    }
    
    private func mergeRoadmaps(local: StudyRoadmap, cloud: StudyRoadmap) -> StudyRoadmap {
        // Merge strategy: use the most recently updated version
        var merged = local
        
        for cloudGoal in cloud.goals {
            if let localIndex = merged.goals.firstIndex(where: { $0.id == cloudGoal.id }) {
                // Goal exists in both - use the newer one
                if cloudGoal.updatedAt > merged.goals[localIndex].updatedAt {
                    merged.goals[localIndex] = cloudGoal
                }
            } else {
                // Goal only exists in cloud - add it
                merged.goals.append(cloudGoal)
            }
        }
        
        return merged
    }
}

// MARK: - Sync Status
public enum SyncStatus {
    case idle
    case syncing
    case synced
    case failed
    
    var description: String {
        switch self {
        case .idle: return "Ready"
        case .syncing: return "Syncing..."
        case .synced: return "Synced to iCloud"
        case .failed: return "Not synced - please check network settings and be sure iCloud is connected"
        }
    }
}
