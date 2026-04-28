import SwiftUI

/// Single swipeable card for study buddy recommendation
struct StudyBuddyCard: View {
    let recommendation: StudyBuddyRecommendation
    let onSwipe: (SwipeAction) -> Void
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    // Swipe threshold
    private let swipeThreshold: CGFloat = 100
    private let rotationMultiplier: Double = 0.05
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - 40, 380)
            let cardHeight = min(geometry.size.height * 0.65, 520)
            
            ZStack {
                // Card background with gradient
                cardBackground
                    .cornerRadius(20)
                
                // Card content
                VStack(spacing: 6) {
                    // Profile header
                    profileHeader
                        .padding(.top, 4)
                    
                    // Compatibility score section
                    compatibilitySection
                    
                    Spacer(minLength: 4)
                    
                    // Match reasons
                    matchReasonsSection
                    
                    // Bottom info
                    bottomInfoSection
                        .padding(.bottom, 2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                
                // Swipe indicators
                swipeIndicators
            }
            .frame(width: cardWidth, height: cardHeight)
            .background(Color.black.opacity(0.95)) // Ensure solid background
            .cornerRadius(20)
            .clipped() // Prevent content overflow
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width) * rotationMultiplier
                        
                        // Subtle scale effect
                        let dragDistance = sqrt(pow(gesture.translation.width, 2) + pow(gesture.translation.height, 2))
                        scale = 1.0 - min(dragDistance / 1000, 0.1)
                    }
                    .onEnded { gesture in
                        handleSwipeEnd(translation: gesture.translation)
                    }
            )
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: offset)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: rotation)
        }
    }
    
    // MARK: - Card Background
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(recommendation.scoreCategory.color).opacity(0.1),
                Color.black.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar
            if let avatarId = recommendation.user.avatarId {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.purple)
            } else {
                Circle()
                    .fill(LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(recommendation.user.fullName.prefix(1))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.user.fullName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                // Test User Badge
                if recommendation.user.isTestUser {
                    HStack(spacing: 3) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 9))
                        Text("Sample Profile")
                            .font(.system(size: 9))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                    )
                }
                
                if let academicYear = recommendation.user.academicYear {
                    Text(academicYear)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                if let major = recommendation.user.major {
                    HStack(spacing: 3) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 10))
                        Text(major)
                            .font(.caption)
                    }
                    .foregroundColor(.purple.opacity(0.9))
                    .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Compatibility Section
    
    private var compatibilitySection: some View {
        VStack(spacing: 4) {
            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: recommendation.compatibilityScore)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(recommendation.scoreCategory.color),
                                Color(recommendation.scoreCategory.color).opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(recommendation.scorePercentage)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("MATCH")
                        .font(.system(size: 8))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
            
            // Category badge
            HStack(spacing: 3) {
                Text(recommendation.scoreCategory.emoji)
                    .font(.system(size: 10))
                Text(recommendation.scoreCategory.rawValue)
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color(recommendation.scoreCategory.color).opacity(0.3))
            )
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Match Reasons
    
    private var matchReasonsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Why you match")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            ForEach(recommendation.topReasons) { reason in
                HStack(spacing: 6) {
                    Image(systemName: reason.category.icon)
                        .font(.system(size: 10))
                        .foregroundColor(Color(reason.category.color))
                        .frame(width: 16)
                    
                    Text(reason.description)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.vertical, 3)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.05))
                )
            }
        }
    }
    
    // MARK: - Bottom Info
    
    private var bottomInfoSection: some View {
        HStack(spacing: 8) {
            // Location
            HStack(spacing: 2) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 9))
                Text("\(recommendation.user.city), \(recommendation.user.state)")
                    .font(.system(size: 9))
                    .lineLimit(1)
            }
            .foregroundColor(.gray)
            
            Spacer()
            
            // Distance
            if recommendation.features.distanceMiles < 50 {
                HStack(spacing: 2) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9))
                    Text(String(format: "%.1f mi", recommendation.features.distanceMiles))
                        .font(.system(size: 9))
                        .lineLimit(1)
                }
                .foregroundColor(.green.opacity(0.8))
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
    }
    
    // MARK: - Swipe Indicators
    
    private var swipeIndicators: some View {
        ZStack {
            // Like indicator (right swipe)
            if offset.width > 50 {
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding(30)
                    }
                    
                    Spacer()
                }
                .opacity(min(Double(offset.width) / swipeThreshold, 1.0))
            }
            
            // Pass indicator (left swipe)
            if offset.width < -50 {
                VStack {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.8))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "xmark")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(30)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .opacity(min(Double(-offset.width) / swipeThreshold, 1.0))
            }
        }
    }
    
    // MARK: - Swipe Handling
    
    private func handleSwipeEnd(translation: CGSize) {
        let swipeDistance = abs(translation.width)
        
        if swipeDistance > swipeThreshold {
            // Determine swipe direction
            let action: SwipeAction = translation.width > 0 ? .like : .pass
            
            // Animate card off screen
            withAnimation(.easeOut(duration: 0.3)) {
                offset = CGSize(
                    width: translation.width > 0 ? 500 : -500,
                    height: translation.height
                )
                rotation = translation.width > 0 ? 20 : -20
            }
            
            // Notify parent after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipe(action)
            }
        } else {
            // Reset position
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = .zero
                rotation = 0
                scale = 1.0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        StudyBuddyCard(
            recommendation: StudyBuddyRecommendation(
                user: User(
                    email: "jane@example.com",
                    fullName: "Jane Smith",
                    college: "MIT",
                    state: "MA",
                    city: "Cambridge",
                    favoriteCoffee: "Latte",
                    favoriteCoffeeShop: "Starbucks",
                    major: "Computer Science",
                    graduationYear: 2026,
                    studyStreak: 7
                ),
                compatibilityScore: 0.87,
                matchReasons: [
                    MatchReason(
                        category: .sharedCourse,
                        description: "You share 2 courses together",
                        impact: 0.4
                    ),
                    MatchReason(
                        category: .sameMajor,
                        description: "Both studying Computer Science",
                        impact: 0.3
                    ),
                    MatchReason(
                        category: .nearbyLocation,
                        description: "Only 2.3 miles away",
                        impact: 0.35
                    )
                ],
                features: MatchFeatures(
                    sharedCoursesCount: 2,
                    courseOverlapRatio: 0.5,
                    sameMajor: true,
                    sameCollege: true,
                    graduationYearDifference: 0,
                    distanceMiles: 2.3,
                    sameCity: true,
                    sameState: true,
                    studyHoursDifference: 3,
                    totalSessionsDifference: 5,
                    studyStreakSimilarity: 0.8,
                    bothRecentlyActive: true,
                    isTutorMatch: false,
                    hasOverlappingTutorSubjects: false,
                    accountAgeDays: 45,
                    lastActiveDaysDifference: 0.5
                )
            ),
            onSwipe: { action in
                print("Swiped: \(action)")
            }
        )
    }
}
