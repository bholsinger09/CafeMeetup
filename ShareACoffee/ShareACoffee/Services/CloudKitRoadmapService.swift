import Foundation
import CloudKit

/// CloudKit service for syncing Study Roadmap data to cloud
public class CloudKitRoadmapService {
    private lazy var container: CKContainer = CKContainer.default()
    private lazy var database: CKDatabase = container.privateCloudDatabase
    private let recordType = "StudyGoal"
    private let roadmapRecordType = "StudyRoadmap"
    
    public init() {
        // Initialization deferred - CloudKit access is lazy
    }
    
    // MARK: - Availability Check
    
    public func isCloudKitAvailable() async -> Bool {
        do {
            print("[CloudKitRoadmapService] ✓ Checking CloudKit availability...")
            let status = try await container.accountStatus()
            print("[CloudKitRoadmapService] ✓ Account status: \(status.rawValue)")
            
            switch status {
            case .available:
                print("[CloudKitRoadmapService] ✅ CloudKit is AVAILABLE")
                return true
            case .restricted:
                print("[CloudKitRoadmapService] ❌ CloudKit is RESTRICTED")
                return false
            case .noAccount:
                print("[CloudKitRoadmapService] ❌ No iCloud account signed in")
                return false
            case .temporarilyUnavailable:
                print("[CloudKitRoadmapService] ⚠️ CloudKit temporarily unavailable")
                return false
            @unknown default:
                print("[CloudKitRoadmapService] ❓ Unknown CloudKit status")
                return false
            }
        } catch {
            print("[CloudKitRoadmapService] ❌ ERROR checking availability:")
            print("[CloudKitRoadmapService]    Domain: \((error as NSError).domain)")
            print("[CloudKitRoadmapService]    Code: \((error as NSError).code)")
            print("[CloudKitRoadmapService]    Message: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Fetch Roadmap from Cloud
    
    public func fetchRoadmap(userId: String) async throws -> StudyRoadmap {
        let predicate = NSPredicate(format: "userId == %@", userId)
        let query = CKQuery(recordType: roadmapRecordType, predicate: predicate)
        // Don't set sortDescriptors - sort in-memory instead since fields may only be queryable
        
        let (resultIds, _) = try await database.records(matching: query)
        
        guard let (_, result) = resultIds.first else {
            // Return empty roadmap if none exists
            return StudyRoadmap(userId: userId)
        }
        
        if case .success(let roadmapRecord) = result {
            return decodeRoadmapRecord(roadmapRecord)
        }
        
        return StudyRoadmap(userId: userId)
    }
    
    /// Fetch all goals for a user
    public func fetchGoals(userId: String) async throws -> [StudyGoal] {
        print("[CloudKitRoadmapService] 🔍 Fetching goals for userId: \(userId)")
        
        let predicate = NSPredicate(format: "userId == %@ && parentGoalId == NULL", userId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        // Don't set sortDescriptors - sort in-memory instead since fields may only be queryable
        
        do {
            print("[CloudKitRoadmapService]    Executing CloudKit query...")
            let (resultIds, _) = try await database.records(matching: query)
            print("[CloudKitRoadmapService] ✓ Query returned \(resultIds.count) records")
            
            var decodedGoals: [StudyGoal] = []
            
            for (_, result) in resultIds {
                if case .success(let record) = result {
                    decodedGoals.append(decodeGoalRecord(record))
                    print("[CloudKitRoadmapService]    ✓ Decoded: \(record.recordID.recordName)")
                } else if case .failure(let error) = result {
                    print("[CloudKitRoadmapService]    ❌ Failed to decode record: \(error)")
                }
            }
            
            // Sort in-memory by targetDate
            decodedGoals.sort { ($0.targetDate) < ($1.targetDate) }
            
            print("[CloudKitRoadmapService] ✅ Fetched \(decodedGoals.count) goals")
            return decodedGoals
        } catch {
            print("[CloudKitRoadmapService] ❌ ERROR fetching goals:")
            print("[CloudKitRoadmapService]    Domain: \((error as NSError).domain)")
            print("[CloudKitRoadmapService]    Code: \((error as NSError).code)")
            print("[CloudKitRoadmapService]    Message: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Save Goal to Cloud
    
    public func saveGoal(_ goal: StudyGoal, userId: String) async throws {
        print("[CloudKitRoadmapService] 💾 Saving goal to CloudKit...")
        print("[CloudKitRoadmapService]    Title: \(goal.title)")
        print("[CloudKitRoadmapService]    UserId: \(userId)")
        print("[CloudKitRoadmapService]    Goal ID: \(goal.id)")
        
        let record = encodeGoalRecord(goal, userId: userId)
        print("[CloudKitRoadmapService]    Record created, attempting save...")
        
        do {
            let savedRecord = try await database.save(record)
            print("[CloudKitRoadmapService] ✅ Successfully saved goal!")
            print("[CloudKitRoadmapService]    CloudKit Record ID: \(savedRecord.recordID.recordName)")
        } catch {
            print("[CloudKitRoadmapService] ❌ ERROR saving goal to CloudKit:")
            print("[CloudKitRoadmapService]    Domain: \((error as NSError).domain)")
            print("[CloudKitRoadmapService]    Code: \((error as NSError).code)")
            print("[CloudKitRoadmapService]    Message: \(error.localizedDescription)")
            
            // Check if it's a specific CloudKit error
            if let ckError = error as? CKError {
                print("[CloudKitRoadmapService]    CKError Code: \(ckError.code.rawValue)")
                print("[CloudKitRoadmapService]    CKError Details: \(ckError.localizedDescription)")
            }
            
            throw error
        }
    }
    
    /// Batch save multiple goals
    public func saveGoals(_ goals: [StudyGoal], userId: String) async throws {
        print("[CloudKitRoadmapService] 💾 Batch saving \(goals.count) goals...")
        
        let records = goals.map { encodeGoalRecord($0, userId: userId) }
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        var successCount = 0
        var failureCount = 0
        
        operation.perRecordSaveBlock = { recordID, result in
            switch result {
            case .success:
                successCount += 1
                print("[CloudKitRoadmapService]    ✓ Saved: \(recordID.recordName)")
            case .failure(let error):
                failureCount += 1
                print("[CloudKitRoadmapService]    ❌ Failed: \(recordID.recordName)")
                print("[CloudKitRoadmapService]       Error: \(error.localizedDescription)")
            }
        }
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success:
                print("[CloudKitRoadmapService] ✅ Batch save complete: \(successCount) success, \(failureCount) failures")
            case .failure(let error):
                print("[CloudKitRoadmapService] ❌ Batch operation failed: \(error.localizedDescription)")
            }
        }
        
        try await database.add(operation)
    }
    
    // MARK: - Delete Goal from Cloud
    
    public func deleteGoal(_ goal: StudyGoal) async throws {
        if let recordId = goal.cloudKitRecordId {
            let recordID = CKRecord.ID(recordName: recordId)
            try await database.deleteRecord(withID: recordID)
            print("[CloudKitRoadmapService] Deleted goal from cloud: \(goal.title)")
        }
    }
    
    // MARK: - Subscriptions for Real-time Sync
    
    /// Subscribe to changes on a specific goal
    public func subscribeToGoalChanges(goalId: String, userId: String) async throws {
        let predicate = NSPredicate(format: "id == %@ && userId == %@", goalId, userId)
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: predicate,
            subscriptionID: "goal_\(goalId)",
            options: [.firesOnRecordUpdate, .firesOnRecordCreation]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.desiredKeys = ["currentProgress", "status", "completedMilestoneIds"]
        notificationInfo.shouldBadge = true
        notificationInfo.alertBody = "Goal progress updated"
        subscription.notificationInfo = notificationInfo
        
        _ = try await database.save(subscription)
        print("[CloudKitRoadmapService] Subscribed to goal changes: \(goalId)")
    }
    
    // MARK: - Encoding/Decoding
    
    private func encodeGoalRecord(_ goal: StudyGoal, userId: String) -> CKRecord {
        let record: CKRecord
        
        if let recordId = goal.cloudKitRecordId {
            record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: recordId))
        } else {
            record = CKRecord(recordType: recordType)
        }
        
        record["userId"] = userId as CKRecordValue
        record["title"] = goal.title as CKRecordValue
        record["description"] = goal.description as CKRecordValue?
        record["category"] = goal.category.rawValue as CKRecordValue
        record["targetDate"] = goal.targetDate as CKRecordValue
        record["currentProgress"] = goal.currentProgress as CKRecordValue
        record["targetValue"] = goal.targetValue as CKRecordValue?
        record["status"] = goal.status.rawValue as CKRecordValue
        record["parentGoalId"] = goal.parentGoalId as CKRecordValue?
        
        if !goal.completedMilestoneIds.isEmpty {
            record["completedMilestoneIds"] = Array(goal.completedMilestoneIds) as CKRecordValue
        } else {
            record["completedMilestoneIds"] = [""] as CKRecordValue
        }
        
        record["createdAt"] = goal.createdAt as CKRecordValue
        record["updatedAt"] = goal.updatedAt as CKRecordValue
        
        // Encode milestones as JSON
        if let milestonesData = try? JSONEncoder().encode(goal.milestones) {
            record["milestones"] = String(data: milestonesData, encoding: .utf8) as CKRecordValue?
        }
        
        return record
    }
    
    private func decodeGoalRecord(_ record: CKRecord) -> StudyGoal {
        var milestones: [StudyMilestone] = []
        
        if let milestonesJson = record["milestones"] as? String,
           let data = milestonesJson.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([StudyMilestone].self, from: data) {
            milestones = decoded
        }
        
        let completedIds = record["completedMilestoneIds"] as? [String] ?? []
        
        return StudyGoal(
            id: record.recordID.recordName,
            title: record["title"] as? String ?? "",
            description: record["description"] as? String,
            category: GoalCategory(rawValue: record["category"] as? String ?? "other") ?? .other,
            targetDate: record["targetDate"] as? Date ?? Date(),
            currentProgress: record["currentProgress"] as? Int ?? 0,
            targetValue: record["targetValue"] as? Int,
            milestones: milestones,
            completedMilestoneIds: Set(completedIds),
            status: GoalStatus(rawValue: record["status"] as? String ?? "notStarted") ?? .notStarted,
            parentGoalId: record["parentGoalId"] as? String,
            isLocalOnly: false,
            lastSyncedAt: Date(),
            cloudKitRecordId: record.recordID.recordName
        )
    }
    
    private func decodeRoadmapRecord(_ record: CKRecord) -> StudyRoadmap {
        // This would decode the roadmap collection record
        return StudyRoadmap(userId: record["userId"] as? String ?? "")
    }
    
    // MARK: - Conflict Resolution
    
    /// Handle merge conflicts when syncing
    private func resolveConflict(local: StudyGoal, remote: StudyGoal) -> StudyGoal {
        // Use the most recently updated version
        if remote.updatedAt > local.updatedAt {
            return remote
        }
        return local
    }
}
