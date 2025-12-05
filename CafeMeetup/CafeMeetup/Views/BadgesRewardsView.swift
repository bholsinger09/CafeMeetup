import SwiftUI

/// Badges & Rewards View - Unique gamification feature for LatteLink
struct BadgesRewardsView: View {
    @StateObject private var experienceService = CoffeeExperienceService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Rewards Summary Card
                    RewardsSummaryCard(rewards: experienceService.userRewards)
                        .padding()
                    
                    // Tab Selector
                    Picker("View", selection: $selectedTab) {
                        Text("Unlocked").tag(0)
                        Text("Locked").tag(1)
                        Text("Stats").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content
                    if selectedTab == 0 {
                        UnlockedBadgesSection(badges: experienceService.getUnlockedBadges())
                    } else if selectedTab == 1 {
                        LockedBadgesSection(badges: experienceService.getLockedBadges())
                    } else {
                        StatsSection(
                            rewards: experienceService.userRewards,
                            checkIns: experienceService.userCheckIns
                        )
                    }
                }
            }
            .navigationTitle("Rewards & Badges")
        }
    }
}

struct RewardsSummaryCard: View {
    let rewards: CoffeeRewards
    
    var body: some View {
        VStack(spacing: 16) {
            // Level & Title
            VStack(spacing: 8) {
                Text("Level \(rewards.level)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(rewards.currentLevelName)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(rewards.points) points")
                        .font(.caption)
                    Spacer()
                    Text("\(rewards.pointsToNextLevel) to next level")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressPercentage)
                    }
                }
                .frame(height: 8)
            }
            
            // Stats Row
            HStack(spacing: 20) {
                StatItem(icon: "flame.fill", value: "\(rewards.streak)", label: "Day Streak", color: .orange)
                StatItem(icon: "checkmark.circle.fill", value: "\(rewards.totalCheckIns)", label: "Check-ins", color: .green)
                StatItem(icon: "star.fill", value: "\(rewards.unlockedBadges.count)", label: "Badges", color: .yellow)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var progressPercentage: Double {
        let levelPoints = rewards.points % 100
        return Double(levelPoints) / 100.0
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UnlockedBadgesSection: View {
    let badges: [CoffeeBadge]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(badges) { badge in
                BadgeCard(badge: badge, isUnlocked: true)
            }
        }
        .padding()
        
        if badges.isEmpty {
            EmptyStateView(
                icon: "star.circle",
                title: "No Badges Yet",
                message: "Start checking in at cafés and going on dates to unlock badges!"
            )
            .padding()
        }
    }
}

struct LockedBadgesSection: View {
    let badges: [CoffeeBadge]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(badges) { badge in
                BadgeCard(badge: badge, isUnlocked: false)
            }
        }
        .padding()
    }
}

struct BadgeCard: View {
    let badge: CoffeeBadge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? rarityColor : Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Text(badge.emoji)
                    .font(.system(size: 40))
                    .grayscale(isUnlocked ? 0 : 1)
                    .opacity(isUnlocked ? 1 : 0.5)
            }
            
            // Badge Info
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.rarity.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(rarityColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(rarityColor.opacity(0.2))
                    .cornerRadius(4)
                
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 4)
                
                if !isUnlocked {
                    Text(badge.unlockCriteria)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var rarityColor: Color {
        switch badge.rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

struct StatsSection: View {
    let rewards: CoffeeRewards
    let checkIns: [CafeCheckIn]
    
    var body: some View {
        VStack(spacing: 20) {
            // Overall Stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Journey")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    StatsRow(label: "Total Check-ins", value: "\(rewards.totalCheckIns)")
                    StatsRow(label: "Study Sessions", value: "\(rewards.totalStudySessions)")
                    StatsRow(label: "Unique Cafés", value: "\(rewards.uniqueCafesVisited.count)")
                    StatsRow(label: "Current Streak", value: "\(rewards.streak) days")
                    StatsRow(label: "Badges Earned", value: "\(rewards.unlockedBadges.count)/\(CoffeeBadgeSystem.allBadges.count)")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // Recent Check-ins
            if !checkIns.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Check-ins")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(checkIns.prefix(5)) { checkIn in
                        CheckInRow(checkIn: checkIn)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct StatsRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

struct CheckInRow: View {
    let checkIn: CafeCheckIn
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: checkIn.matchId != nil ? "heart.circle.fill" : "cup.and.saucer.fill")
                .foregroundColor(checkIn.matchId != nil ? .pink : .brown)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(checkIn.cafeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(checkIn.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let coffee = checkIn.coffeeOrdered {
                    Text("☕️ \(coffee)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    BadgesRewardsView()
}
