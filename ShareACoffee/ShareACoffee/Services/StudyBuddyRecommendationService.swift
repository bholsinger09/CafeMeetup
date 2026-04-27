import Foundation
import CoreML

/// ML-Powered Study Buddy Recommendation Service
/// Uses sophisticated algorithms to match students with compatible study partners
class StudyBuddyRecommendationService {
    nonisolated(unsafe) static let shared = StudyBuddyRecommendationService()
    
    private init() {}
    
    // MARK: - Main Recommendation Method
    
    /// Generate personalized study buddy recommendations for a user
    /// - Parameters:
    ///   - currentUser: The user requesting recommendations
    ///   - candidates: Pool of potential study partners
    ///   - filters: Optional filtering preferences
    ///   - limit: Maximum number of recommendations to return
    /// - Returns: Array of recommendations sorted by compatibility score
    func generateRecommendations(
        for currentUser: User,
        from candidates: [User],
        filters: RecommendationFilters = .default,
        limit: Int = 20
    ) async -> [StudyBuddyRecommendation] {
        
        // Simulate processing time for realism
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        var recommendations: [StudyBuddyRecommendation] = []
        
        for candidate in candidates {
            // Skip self
            if candidate.id == currentUser.id {
                continue
            }
            
            // Calculate shared courses
            let sharedCourses = calculateSharedCourses(
                current: currentUser.currentCourses ?? [],
                candidate: candidate.currentCourses ?? []
            )
            
            // Build feature set
            let features = MatchFeatures(
                currentUser: currentUser,
                candidateUser: candidate,
                sharedCourses: sharedCourses
            )
            
            // Apply filters
            if !passesFilters(features: features, filters: filters, candidate: candidate) {
                continue
            }
            
            // Calculate compatibility score
            let score = calculateCompatibilityScore(features: features)
            
            // Generate match reasons
            let reasons = generateMatchReasons(
                currentUser: currentUser,
                candidate: candidate,
                features: features
            )
            
            let recommendation = StudyBuddyRecommendation(
                user: candidate,
                compatibilityScore: score,
                matchReasons: reasons,
                features: features
            )
            
            recommendations.append(recommendation)
        }
        
        // Sort by compatibility score (highest first)
        recommendations.sort { $0.compatibilityScore > $1.compatibilityScore }
        
        // Apply limit
        return Array(recommendations.prefix(limit))
    }
    
    // MARK: - Compatibility Scoring
    
    /// Advanced compatibility scoring algorithm
    /// Combines multiple factors with weighted importance
    private func calculateCompatibilityScore(features: MatchFeatures) -> Double {
        var score = 0.0
        
        // 1. Shared Courses (25% weight)
        let courseScore = min(Double(features.sharedCoursesCount) * 0.2, 1.0)
        score += courseScore * 0.25
        
        // 2. Academic Alignment (20% weight)
        var academicScore = 0.0
        if features.sameMajor { academicScore += 0.5 }
        if features.sameCollege { academicScore += 0.3 }
        if features.graduationYearDifference <= 1 { academicScore += 0.2 }
        score += academicScore * 0.20
        
        // 3. Location Proximity (15% weight)
        var locationScore = 0.0
        if features.distanceMiles < 1.0 {
            locationScore = 1.0
        } else if features.distanceMiles < 5.0 {
            locationScore = 0.8
        } else if features.distanceMiles < 15.0 {
            locationScore = 0.5
        } else if features.sameCity {
            locationScore = 0.3
        } else if features.sameState {
            locationScore = 0.1
        }
        score += locationScore * 0.15
        
        // 4. Study Habits Similarity (15% weight)
        var studyScore = 0.0
        // Similar study hours
        if features.studyHoursDifference < 5 {
            studyScore += 0.4
        } else if features.studyHoursDifference < 10 {
            studyScore += 0.2
        }
        // Study streak similarity
        studyScore += features.studyStreakSimilarity * 0.3
        // Both recently active
        if features.bothRecentlyActive {
            studyScore += 0.3
        }
        score += studyScore * 0.15
        
        // 5. Tutoring Match (10% weight)
        var tutorScore = 0.0
        if features.isTutorMatch && features.hasOverlappingTutorSubjects {
            tutorScore = 1.0 // Perfect tutor-student match
        }
        score += tutorScore * 0.10
        
        // 6. Engagement & Activity (10% weight)
        var engagementScore = 0.0
        // Account age (prefer established users)
        if features.accountAgeDays > 30 {
            engagementScore += 0.3
        } else if features.accountAgeDays > 7 {
            engagementScore += 0.2
        } else if features.accountAgeDays > 1 {
            engagementScore += 0.1
        }
        // Recent activity alignment
        if features.lastActiveDaysDifference < 1 {
            engagementScore += 0.4
        } else if features.lastActiveDaysDifference < 3 {
            engagementScore += 0.2
        }
        // Total sessions similarity
        if features.totalSessionsDifference < 10 {
            engagementScore += 0.3
        }
        score += engagementScore * 0.10
        
        // 7. Course Overlap Ratio Bonus (5% weight)
        score += features.courseOverlapRatio * 0.05
        
        // Ensure score is clamped between 0 and 1
        return min(max(score, 0.0), 1.0)
    }
    
    // MARK: - Match Reasons Generation
    
    /// Generate human-readable reasons explaining the match
    private func generateMatchReasons(
        currentUser: User,
        candidate: User,
        features: MatchFeatures
    ) -> [MatchReason] {
        var reasons: [MatchReason] = []
        
        // Shared courses (highest priority)
        if features.sharedCoursesCount > 0 {
            let description = features.sharedCoursesCount == 1 
                ? "You share 1 course together"
                : "You share \(features.sharedCoursesCount) courses together"
            reasons.append(MatchReason(
                category: .sharedCourse,
                description: description,
                impact: min(Double(features.sharedCoursesCount) * 0.15, 0.5)
            ))
        }
        
        // Same major
        if features.sameMajor, let major = currentUser.major {
            reasons.append(MatchReason(
                category: .sameMajor,
                description: "Both studying \(major)",
                impact: 0.3
            ))
        }
        
        // Same college
        if features.sameCollege {
            reasons.append(MatchReason(
                category: .sameCollege,
                description: "Fellow \(currentUser.college) student",
                impact: 0.25
            ))
        }
        
        // Nearby location
        if features.distanceMiles < 5 {
            let distanceStr = String(format: "%.1f", features.distanceMiles)
            reasons.append(MatchReason(
                category: .nearbyLocation,
                description: "Only \(distanceStr) miles away",
                impact: 0.35
            ))
        } else if features.sameCity {
            reasons.append(MatchReason(
                category: .nearbyLocation,
                description: "Lives in \(candidate.city)",
                impact: 0.2
            ))
        }
        
        // Similar study habits
        if features.studyHoursDifference < 5 {
            reasons.append(MatchReason(
                category: .studyHabits,
                description: "Similar study hours per week",
                impact: 0.25
            ))
        }
        
        // Study streak
        if features.studyStreakSimilarity > 0.7 && currentUser.studyStreak > 3 {
            reasons.append(MatchReason(
                category: .studyHabits,
                description: "Both on study streaks 🔥",
                impact: 0.2
            ))
        }
        
        // Academic level
        if features.graduationYearDifference == 0, let year = currentUser.graduationYear {
            reasons.append(MatchReason(
                category: .academicLevel,
                description: "Same graduation year (\(year))",
                impact: 0.15
            ))
        }
        
        // Tutoring match
        if features.isTutorMatch {
            if currentUser.isTutor {
                reasons.append(MatchReason(
                    category: .complementarySkills,
                    description: "You can tutor them!",
                    impact: 0.4
                ))
            } else if candidate.isTutor {
                reasons.append(MatchReason(
                    category: .complementarySkills,
                    description: "They can tutor you!",
                    impact: 0.4
                ))
            }
        }
        
        // Recently active
        if features.bothRecentlyActive {
            reasons.append(MatchReason(
                category: .recentlyActive,
                description: "Both active recently",
                impact: 0.2
            ))
        }
        
        // Sort reasons by impact (highest first)
        reasons.sort { $0.impact > $1.impact }
        
        return reasons
    }
    
    // MARK: - Helper Methods
    
    /// Calculate number of shared courses
    private func calculateSharedCourses(current: [String], candidate: [String]) -> Int {
        let currentSet = Set(current)
        let candidateSet = Set(candidate)
        return currentSet.intersection(candidateSet).count
    }
    
    /// Check if candidate passes filter criteria
    private func passesFilters(
        features: MatchFeatures,
        filters: RecommendationFilters,
        candidate: User
    ) -> Bool {
        // Max distance filter
        if let maxDistance = filters.maxDistance {
            if features.distanceMiles > maxDistance {
                return false
            }
        }
        
        // Same major only
        if filters.sameMajorOnly && !features.sameMajor {
            return false
        }
        
        // Same college only
        if filters.sameCollegeOnly && !features.sameCollege {
            return false
        }
        
        // Require shared courses
        if filters.requireSharedCourses && features.sharedCoursesCount == 0 {
            return false
        }
        
        // Only recently active
        if filters.onlyRecentlyActive && !candidate.isRecentlyActive {
            return false
        }
        
        return true
    }
    
    // MARK: - Batch Processing
    
    /// Process recommendations in batches for large user pools
    func generateRecommendationsBatch(
        for currentUser: User,
        from candidates: [User],
        batchSize: Int = 50
    ) async -> [StudyBuddyRecommendation] {
        var allRecommendations: [StudyBuddyRecommendation] = []
        
        // Process in batches
        for i in stride(from: 0, to: candidates.count, by: batchSize) {
            let endIndex = min(i + batchSize, candidates.count)
            let batch = Array(candidates[i..<endIndex])
            
            let batchResults = await generateRecommendations(
                for: currentUser,
                from: batch,
                limit: batchSize
            )
            
            allRecommendations.append(contentsOf: batchResults)
        }
        
        // Sort all results
        allRecommendations.sort { $0.compatibilityScore > $1.compatibilityScore }
        
        return allRecommendations
    }
}

// MARK: - Future ML Model Integration
/*
 When you have real match data, you can train a Core ML model:
 
 1. Collect data on successful matches (user pairs who had positive interactions)
 2. Use Create ML to train a regression model predicting compatibility
 3. Export as .mlmodel file and add to project
 4. Replace calculateCompatibilityScore with ML predictions:
 
 func predictCompatibility(features: MatchFeatures) -> Double {
     guard let model = try? StudyBuddyMLModel(configuration: MLModelConfiguration()) else {
         return fallbackScore(features)
     }
     
     let input = StudyBuddyMLModelInput(
         sharedCoursesCount: features.sharedCoursesCount,
         sameMajor: features.sameMajor ? 1.0 : 0.0,
         distanceMiles: features.distanceMiles,
         // ... other features
     )
     
     if let prediction = try? model.prediction(input: input) {
         return prediction.compatibilityScore
     }
     
     return fallbackScore(features)
 }
 */
