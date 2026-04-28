import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showEditProfile = false
    @State private var showSignOutAlert = false
    @State private var showAvatarPicker = false
    @State private var selectedAvatarId: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        if let profileImageURL = authViewModel.currentUser?.profileImageURL,
                           let uiImage = UIImage.fromBase64String(profileImageURL) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 12)
                        } else {
                            Circle()
                                .fill(themeManager.currentTheme.primaryGradient)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(authViewModel.currentUser?.fullName.prefix(1) ?? "?")
                                        .font(.system(size: 40, weight: .semibold))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 12)
                        }
                        
                        VStack(spacing: 4) {
                            Text(authViewModel.currentUser?.fullName ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.lightText)
                            
                            Text(authViewModel.currentUser?.college ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            Button {
                                showAvatarPicker = true
                            } label: {
                                HStack {
                                    Text(currentAvatar.emoji)
                                        .font(.title3)
                                    Text("Change Avatar")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(themeManager.currentTheme.primaryGradient)
                                .cornerRadius(20)
                                .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 8)
                            }
                            
                            Button {
                                showEditProfile = true
                            } label: {
                                Text("Edit Profile")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(themeManager.currentTheme.primaryGradient)
                                    .cornerRadius(20)
                                    .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 8)
                            }
                        }
                    }
                    .padding()
                    
                    // Profile Details
                    VStack(spacing: 0) {
                        ProfileDetailRow(icon: "envelope.fill", title: "Email", value: authViewModel.currentUser?.email ?? "")
                        
                        Divider().padding(.leading, 50)
                        
                        ProfileDetailRow(icon: "location.fill", title: "Location", value: "\(authViewModel.currentUser?.city ?? ""), \(authViewModel.currentUser?.state ?? "")")
                        
                        Divider().padding(.leading, 50)
                        
                        ProfileDetailRow(icon: "cup.and.saucer.fill", title: "Favorite Coffee", value: authViewModel.currentUser?.favoriteCoffee ?? "")
                        
                        Divider().padding(.leading, 50)
                        
                        ProfileDetailRow(icon: "building.2.fill", title: "Favorite Shop", value: authViewModel.currentUser?.favoriteCoffeeShop ?? "")
                        
                        if let gender = authViewModel.currentUser?.gender, !gender.isEmpty {
                            Divider().padding(.leading, 50)
                            ProfileDetailRow(icon: "person.fill", title: "Gender", value: gender)
                        }
                    }
                    .background(themeManager.currentTheme.cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: themeManager.currentTheme.accentColor.opacity(0.1), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.currentTheme.accentColor.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Me")
                                .font(.headline)
                            
                            Text(bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(themeManager.currentTheme.cardBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: themeManager.currentTheme.accentColor.opacity(0.1), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.currentTheme.accentColor.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Academic Section (Emphasizes Student Identity)
                    VStack(spacing: 12) {
                        // My Classes Button
                        NavigationLink {
                            MyCoursesView()
                        } label: {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("My Classes")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.accentColor)
                            .cornerRadius(12)
                            .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 8)
                        }
                        
                        // Academic Info Display
                        if let major = authViewModel.currentUser?.major,
                           let year = authViewModel.currentUser?.academicYear {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Major")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(major)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Year")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(year)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding()
                            .background(themeManager.currentTheme.cardBackgroundColor)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Customization & Achievements Section
                    VStack(spacing: 12) {
                        // Theme Customization Button
                        NavigationLink {
                            ProfileCustomizationView()
                        } label: {
                            HStack {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Study Aesthetics")
                                        .font(.headline)
                                    Text("Customize your theme")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        }
                        
                        // Achievements Button
                        NavigationLink {
                            AchievementsView()
                        } label: {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Achievements")
                                        .font(.headline)
                                    let manager = AchievementManager.shared
                                    Text("\(manager.unlockedCount) of \(manager.totalCount) unlocked")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Rewards & Achievements Section
                    RewardsPreviewCard()
                        .padding(.horizontal)
                    
                    // Account Actions Section
                    VStack(spacing: 12) {
                        // Account Settings Button
                        NavigationLink {
                            AccountSettingsView()
                        } label: {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                Text("Account Settings")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.cardBackgroundColor)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Sign Out Button
                        Button {
                            showSignOutAlert = true
                        } label: {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.8), Color.red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.red.opacity(0.3), radius: 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .background(themeManager.currentTheme.primaryGradient)
            .navigationTitle("Profile")
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerView(selectedAvatarId: $selectedAvatarId)
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .onAppear {
                selectedAvatarId = authViewModel.currentUser?.avatarId
            }
            .onChange(of: selectedAvatarId) { oldValue, newValue in
                // Update user's avatar in auth view model
                if var user = authViewModel.currentUser {
                    user.avatarId = newValue
                    authViewModel.currentUser = user
                    // Avatar changes are persisted via AuthenticationViewModel
                }
            }
        }
    }
    
    private var currentAvatar: Avatar {
        if let avatarId = selectedAvatarId ?? authViewModel.currentUser?.avatarId,
           let avatar = AvatarSystem.avatar(withId: avatarId) {
            return avatar
        }
        return AvatarSystem.defaultAvatar
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.primaryPink)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Rewards Preview Card

struct RewardsPreviewCard: View {
    @State private var rewards = CoffeeRewards(
        points: 150,
        level: 3,
        streak: 5,
        totalCheckIns: 8,
        totalStudySessions: 2,
        uniqueCafesVisited: ["cafe1", "cafe2", "cafe3"],
        unlockedBadges: ["first_latte", "social_butterfly", "morning_person"]
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏆 Rewards & Achievements")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                NavigationLink {
                    FullRewardsView()
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.primaryPink)
                }
            }
            
            // Level Display
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(rewards.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text(rewards.currentLevelName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(rewards.points) pts")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("\(rewards.pointsToNextLevel) to next")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                    
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
            
            // Quick Stats
            HStack(spacing: 20) {
                QuickStat(icon: "flame.fill", value: "\(rewards.streak)", label: "Streak", color: .orange)
                QuickStat(icon: "star.fill", value: "\(rewards.unlockedBadges.count)", label: "Badges", color: .yellow)
                QuickStat(icon: "location.fill", value: "\(rewards.uniqueCafesVisited.count)", label: "Cafés", color: .green)
            }
        }
        .padding()
        .background(Color.darkSecondary)
        .cornerRadius(12)
        .shadow(color: Color.primaryPink.opacity(0.1), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var progressPercentage: Double {
        let levelPoints = rewards.points % 100
        return Double(levelPoints) / 100.0
    }
}

struct QuickStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Full Rewards View

struct FullRewardsView: View {
    @State private var rewards = CoffeeRewards(
        points: 150,
        level: 3,
        streak: 5,
        totalCheckIns: 8,
        totalStudySessions: 2,
        uniqueCafesVisited: ["cafe1", "cafe2", "cafe3"],
        unlockedBadges: ["first_latte", "social_butterfly", "morning_person"]
    )
    @State private var selectedTab = 0
    @State private var allBadges = CoffeeBadgeSystem.allBadges
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Rewards Summary
                VStack(spacing: 16) {
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
                        .foregroundColor(.white)
                    
                    // Progress
                    VStack(spacing: 4) {
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
                                    .fill(Color.gray.opacity(0.3))
                                
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
                    .padding(.horizontal)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(icon: "flame.fill", value: "\(rewards.streak)", label: "Day Streak", color: .orange)
                        StatCard(icon: "checkmark.circle.fill", value: "\(rewards.totalCheckIns)", label: "Check-ins", color: .green)
                        StatCard(icon: "star.fill", value: "\(rewards.unlockedBadges.count)", label: "Badges", color: .yellow)
                        StatCard(icon: "book.fill", value: "\(rewards.totalStudySessions)", label: "Study Sessions", color: .purple)
                        StatCard(icon: "cup.and.saucer.fill", value: "\(rewards.uniqueCafesVisited.count)", label: "Unique Cafés", color: .brown)
                        StatCard(icon: "heart.fill", value: "\(rewards.points)", label: "Total Points", color: .pink)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.darkSecondary)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Tabs
                Picker("View", selection: $selectedTab) {
                    Text("Unlocked (\(unlockedBadges.count))").tag(0)
                    Text("Locked (\(lockedBadges.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Badges
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(selectedTab == 0 ? unlockedBadges : lockedBadges) { badge in
                        BadgeCardView(badge: badge)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.darkBackground)
        .navigationTitle("Rewards & Badges")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
    
    private var progressPercentage: Double {
        let levelPoints = rewards.points % 100
        return Double(levelPoints) / 100.0
    }
    
    private var unlockedBadges: [CoffeeBadge] {
        allBadges.filter { rewards.unlockedBadges.contains($0.id) }
            .map { badge in
                var unlocked = badge
                unlocked.isUnlocked = true
                return unlocked
            }
    }
    
    private var lockedBadges: [CoffeeBadge] {
        allBadges.filter { !rewards.unlockedBadges.contains($0.id) }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.darkSecondary.opacity(0.5))
        .cornerRadius(12)
    }
}

struct BadgeCardView: View {
    let badge: CoffeeBadge
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? rarityColor : Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
                
                Text(badge.emoji)
                    .font(.system(size: 35))
                    .grayscale(badge.isUnlocked ? 0 : 1)
                    .opacity(badge.isUnlocked ? 1 : 0.5)
            }
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
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
                    .padding(.top, 2)
                
                if !badge.isUnlocked {
                    Text("🔒 \(badge.unlockCriteria)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color.darkSecondary)
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

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
}
