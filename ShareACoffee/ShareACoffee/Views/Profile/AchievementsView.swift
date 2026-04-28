import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory: AchievementCategory?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: achievementManager.completionPercentage)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: achievementManager.completionPercentage)
                            
                            VStack(spacing: 4) {
                                Text("\(achievementManager.unlockedCount)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                
                                Text("of \(achievementManager.totalCount)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Achievements Unlocked")
                            .font(.headline)
                        
                        Text("\(Int(achievementManager.completionPercentage * 100))% Complete")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterChip(
                                title: "All",
                                icon: "star.fill",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(AchievementCategory.allCases, id: \.self) { category in
                                CategoryFilterChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Achievements Grid
                    let filteredAchievements = selectedCategory == nil
                        ? achievementManager.achievements
                        : achievementManager.achievements.filter { $0.category == selectedCategory }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementBadgeCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Achievements")
            .overlay {
                if let recentlyUnlocked = achievementManager.recentlyUnlocked {
                    AchievementUnlockedOverlay(achievement: recentlyUnlocked)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}

struct AchievementBadgeCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? achievement.category.color.gradient
                            : Color.gray.opacity(0.2).gradient
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: achievement.isUnlocked ? achievement.category.color.opacity(0.3) : .clear,
                        radius: 10
                    )
                
                if achievement.isUnlocked {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                
                // Rarity indicator
                if achievement.isUnlocked {
                    Text(achievement.rarity.emoji)
                        .font(.caption)
                        .offset(x: 30, y: -30)
                }
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Progress bar for locked achievements
                if !achievement.isUnlocked {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(achievement.category.color)
                                .frame(width: geometry.size.width * achievement.progressPercentage, height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(achievement.progress)/\(achievement.requirement)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

struct CategoryFilterChip: View {
    let title: String
    let icon: String
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color(.systemGray6))
            )
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct AchievementUnlockedOverlay: View {
    let achievement: Achievement
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -10
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Badge with animation
                ZStack {
                    Circle()
                        .fill(achievement.category.color.gradient)
                        .frame(width: 120, height: 120)
                        .shadow(color: achievement.category.color.opacity(0.5), radius: 20)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    
                    // Sparkles
                    ForEach(0..<8) { index in
                        Image(systemName: "sparkle")
                            .foregroundColor(.yellow)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 70,
                                y: sin(Double(index) * .pi / 4) * 70
                            )
                            .opacity(opacity)
                    }
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                
                VStack(spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(achievement.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(achievement.category.color)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Text(achievement.rarity.emoji)
                        Text(achievement.rarity.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(achievement.rarity.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                }
                .opacity(opacity)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                scale = 1.0
                rotation = 0
                opacity = 1.0
            }
        }
    }
}

struct CompactAchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? achievement.category.color.gradient
                            : Color.gray.opacity(0.2).gradient
                    )
                    .frame(width: 40, height: 40)
                
                if achievement.isUnlocked {
                    Image(systemName: achievement.icon)
                        .font(.caption)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                if !achievement.isUnlocked {
                    Text("\(achievement.progress)/\(achievement.requirement)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Text(achievement.rarity.emoji)
                    .font(.caption2)
            }
        }
    }
}

#Preview {
    AchievementsView()
}
