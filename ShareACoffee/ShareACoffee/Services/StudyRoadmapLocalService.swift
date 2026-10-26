import Foundation

/// Local storage service for Study Roadmap using UserDefaults and file system
public class StudyRoadmapService {
    private let userId: String
    private let storageKey: String
    private let fileManager = FileManager.default
    private let documentsURL: URL
    
    public init(userId: String) {
        self.userId = userId
        self.storageKey = "studyRoadmap_\(userId)"
        self.documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Local Storage (UserDefaults + File System)
    
    /// Save roadmap to local storage (hybrid: metadata in UserDefaults, full data in file)
    public func saveLocalRoadmap(_ roadmap: StudyRoadmap) {
        do {
            // Save full roadmap to file system for large data
            let fileURL = roadmapFileURL()
            let data = try JSONEncoder().encode(roadmap)
            try data.write(to: fileURL)
            
            // Save sync metadata to UserDefaults
            UserDefaults.standard.set(Date(), forKey: "\(storageKey)_lastSync")
            UserDefaults.standard.set(roadmap.goals.count, forKey: "\(storageKey)_goalCount")
            
            print("[StudyRoadmapService] Saved roadmap locally with \(roadmap.goals.count) goals")
        } catch {
            print("[StudyRoadmapService] Error saving roadmap: \(error)")
        }
    }
    
    /// Load roadmap from local storage
    public func loadLocalRoadmap() -> StudyRoadmap? {
        do {
            let fileURL = roadmapFileURL()
            let data = try Data(contentsOf: fileURL)
            let roadmap = try JSONDecoder().decode(StudyRoadmap.self, from: data)
            print("[StudyRoadmapService] Loaded roadmap from local storage")
            return roadmap
        } catch {
            print("[StudyRoadmapService] No local roadmap found or decode error: \(error)")
            return nil
        }
    }
    
    /// Save individual goal offline (for creating goals without internet)
    public func saveGoalOffline(_ goal: StudyGoal) {
        do {
            let fileURL = offlineGoalFileURL(goalId: goal.id)
            var localGoal = goal
            localGoal.isLocalOnly = true
            let data = try JSONEncoder().encode(localGoal)
            try data.write(to: fileURL)
            
            print("[StudyRoadmapService] Saved goal offline: \(goal.title)")
        } catch {
            print("[StudyRoadmapService] Error saving goal offline: \(error)")
        }
    }
    
    /// Get all offline goals waiting to be synced
    public func getOfflineGoals() -> [StudyGoal] {
        let offlineDir = offlineGoalsDirectoryURL()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: offlineDir, includingPropertiesForKeys: nil)
            var offlineGoals: [StudyGoal] = []
            
            for fileURL in fileURLs where fileURL.pathExtension == "json" {
                if let data = try? Data(contentsOf: fileURL),
                   let goal = try? JSONDecoder().decode(StudyGoal.self, from: data) {
                    offlineGoals.append(goal)
                }
            }
            
            return offlineGoals
        } catch {
            print("[StudyRoadmapService] Error loading offline goals: \(error)")
            return []
        }
    }
    
    /// Delete offline goal after successful cloud sync
    public func deleteOfflineGoal(_ goalId: String) {
        let fileURL = offlineGoalFileURL(goalId: goalId)
        try? fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Cache Management
    
    /// Clear all local cache
    public func clearLocalCache() {
        try? fileManager.removeItem(at: roadmapFileURL())
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: "\(storageKey)_lastSync")
        UserDefaults.standard.removeObject(forKey: "\(storageKey)_goalCount")
    }
    
    // MARK: - Private Helpers
    
    private func roadmapFileURL() -> URL {
        let directoryURL = documentsURL.appendingPathComponent("StudyRoadmaps", isDirectory: true)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent("\(userId)_roadmap.json")
    }
    
    private func offlineGoalsDirectoryURL() -> URL {
        let directoryURL = documentsURL.appendingPathComponent("OfflineGoals", isDirectory: true)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL
    }
    
    private func offlineGoalFileURL(goalId: String) -> URL {
        return offlineGoalsDirectoryURL().appendingPathComponent("\(goalId).json")
    }
}
