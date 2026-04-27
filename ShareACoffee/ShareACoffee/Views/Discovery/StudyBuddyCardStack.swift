import SwiftUI

/// Stack of swipeable study buddy cards
struct StudyBuddyCardStack: View {
    let recommendations: [StudyBuddyRecommendation]
    let onSwipe: (StudyBuddyRecommendation, SwipeAction) -> Void
    let onNeedMore: () -> Void
    
    @State private var currentIndex = 0
    @State private var scale: CGFloat = 1.0
    
    // Number of cards to show in stack
    private let maxVisibleCards = 3
    
    var body: some View {
        ZStack {
            if recommendations.isEmpty {
                emptyState
            } else if currentIndex >= recommendations.count {
                allDoneState
            } else {
                cardStack
            }
        }
    }
    
    // MARK: - Card Stack
    
    private var cardStack: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - 40, 380)
            let cardHeight = min(geometry.size.height * 0.7, 550)
            
            ZStack {
                // Show up to 3 cards stacked (but hide background cards to prevent text overlap)
                ForEach(Array(visibleCards.enumerated()), id: \.offset) { index, recommendation in
                    if index == 0 {
                        // Top card - fully visible and interactive
                        StudyBuddyCard(
                            recommendation: recommendation,
                            onSwipe: { action in
                                handleSwipe(recommendation: recommendation, action: action)
                            }
                        )
                        .zIndex(Double(visibleCards.count))
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    } else {
                        // Background cards - shown as subtle visual hints only (no text)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.2),
                                    Color.black.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: cardWidth, height: cardHeight)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .offset(y: CGFloat(index) * 10)
                            .scaleEffect(1.0 - (CGFloat(index) * 0.05))
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .zIndex(Double(visibleCards.count - index))
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
            }
            
            Text("No Recommendations Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("We're finding the best study buddies for you")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onNeedMore) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - All Done State
    
    private var allDoneState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.green.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            
            Text("All Caught Up!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("You've seen all your recommendations. Check back later for more!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onNeedMore) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Find More")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helpers
    
    private var visibleCards: [StudyBuddyRecommendation] {
        let endIndex = min(currentIndex + maxVisibleCards, recommendations.count)
        return Array(recommendations[currentIndex..<endIndex])
    }
    
    private func handleSwipe(recommendation: StudyBuddyRecommendation, action: SwipeAction) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Notify parent
        onSwipe(recommendation, action)
        
        // Move to next card
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex += 1
        }
        
        // Request more if running low
        if currentIndex >= recommendations.count - 5 {
            onNeedMore()
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        StudyBuddyCardStack(
            recommendations: [
                StudyBuddyRecommendation(
                    user: User(
                        email: "jane@example.com",
                        fullName: "Jane Smith",
                        college: "MIT",
                        state: "MA",
                        city: "Cambridge",
                        favoriteCoffee: "Latte",
                        favoriteCoffeeShop: "Starbucks",
                        major: "Computer Science",
                        graduationYear: 2026
                    ),
                    compatibilityScore: 0.87,
                    matchReasons: [
                        MatchReason(category: .sharedCourse, description: "You share 2 courses", impact: 0.4)
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
                StudyBuddyRecommendation(
                    user: User(
                        email: "john@example.com",
                        fullName: "John Doe",
                        college: "MIT",
                        state: "MA",
                        city: "Boston",
                        favoriteCoffee: "Espresso",
                        favoriteCoffeeShop: "Dunkin",
                        major: "Mathematics",
                        graduationYear: 2025
                    ),
                    compatibilityScore: 0.75,
                    matchReasons: [
                        MatchReason(category: .sameCollege, description: "Fellow MIT student", impact: 0.3)
                    ],
                    features: MatchFeatures(
                        sharedCoursesCount: 1,
                        courseOverlapRatio: 0.3,
                        sameMajor: false,
                        sameCollege: true,
                        graduationYearDifference: 1,
                        distanceMiles: 5.5,
                        sameCity: false,
                        sameState: true,
                        studyHoursDifference: 8,
                        totalSessionsDifference: 12,
                        studyStreakSimilarity: 0.5,
                        bothRecentlyActive: true,
                        isTutorMatch: false,
                        hasOverlappingTutorSubjects: false,
                        accountAgeDays: 30,
                        lastActiveDaysDifference: 1.0
                    )
                )
            ],
            onSwipe: { recommendation, action in
                print("Swiped \(recommendation.user.fullName): \(action)")
            },
            onNeedMore: {
                print("Need more recommendations")
            }
        )
    }
}
