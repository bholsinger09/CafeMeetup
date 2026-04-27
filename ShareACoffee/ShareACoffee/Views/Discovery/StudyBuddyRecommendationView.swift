import SwiftUI

/// Main view for ML-powered study buddy recommendations with swipeable cards
struct StudyBuddyRecommendationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = StudyBuddyRecommendationViewModel()
    
    @State private var showMatchCelebration = false
    @State private var showFilters = false
    @State private var showStatistics = false
    @State private var showPrivacyDisclosure = false
    @State private var hasSeenPrivacyNotice = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.black,
                    Color.purple.opacity(0.2),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Privacy Notice Banner
                if !hasSeenPrivacyNotice {
                    privacyNoticeBanner
                }
                
                // Main content
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error: error)
                } else {
                    mainContent
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            filterSheet
        }
        .sheet(isPresented: $showStatistics) {
            statisticsSheet
        }
        .sheet(isPresented: $showPrivacyDisclosure) {
            PrivacyDisclosureView()
        }
        .overlay(
            matchCelebrationOverlay
        )
        .task {
            if let user = authViewModel.currentUser {
                await viewModel.loadRecommendations(for: user)
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text("Study Buddies")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("ML-Powered Matches")
                    .font(.subheadline)
                    .foregroundColor(.purple.opacity(0.8))
            }
            
            Spacer()
            
            // Statistics button
            Button(action: { showStatistics = true }) {
                VStack(spacing: 2) {
                    Text("\(viewModel.todayMatches)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("matches")
                        .font(.caption2)
                }
                .foregroundColor(.white)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                )
            }
            
            // Filter button
            Button(action: { showFilters = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            
            // Privacy info button
            Button(action: { showPrivacyDisclosure = true }) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    // MARK: - Privacy Notice Banner
    
    private var privacyNoticeBanner: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Privacy Notice")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Some profiles are samples. Tap for details.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { 
                    showPrivacyDisclosure = true 
                }) {
                    Text("Learn More")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.2))
                        )
                }
                
                Button(action: {
                    withAnimation {
                        hasSeenPrivacyNotice = true
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.15),
                        Color.orange.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            Divider()
                .background(Color.orange.opacity(0.3))
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack {
            // Card stack
            StudyBuddyCardStack(
                recommendations: viewModel.recommendations,
                onSwipe: { recommendation, action in
                    viewModel.handleSwipe(recommendation: recommendation, action: action)
                },
                onNeedMore: {
                    Task {
                        await viewModel.refresh()
                    }
                }
            )
            
            // Action buttons
            actionButtons
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 30) {
            // Pass button
            Button(action: {
                viewModel.passCurrentRecommendation()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            .disabled(viewModel.recommendations.isEmpty)
            
            // Refresh button
            Button(action: {
                Task {
                    await viewModel.refresh()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
            }
            
            // Like button
            Button(action: {
                viewModel.likeCurrentRecommendation()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .shadow(color: .green.opacity(0.4), radius: 10)
            }
            .disabled(viewModel.recommendations.isEmpty)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(1.5)
            
            Text("Finding your perfect study buddies...")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                Task {
                    await viewModel.refresh()
                }
            }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Filter Sheet
    
    private var filterSheet: some View {
        NavigationView {
            Form {
                Section("Location") {
                    Toggle("Same College Only", isOn: $viewModel.filters.sameCollegeOnly)
                    
                    HStack {
                        Text("Max Distance")
                        Spacer()
                        if let maxDist = viewModel.filters.maxDistance {
                            Text("\(Int(maxDist)) mi")
                                .foregroundColor(.secondary)
                        } else {
                            Text("Any")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Academic") {
                    Toggle("Same Major Only", isOn: $viewModel.filters.sameMajorOnly)
                    Toggle("Require Shared Courses", isOn: $viewModel.filters.requireSharedCourses)
                }
                
                Section("Activity") {
                    Toggle("Recently Active Only", isOn: $viewModel.filters.onlyRecentlyActive)
                }
                
                Section("Match Quality") {
                    VStack(alignment: .leading) {
                        Text("Minimum Compatibility: \(Int(viewModel.filters.minCompatibilityScore * 100))%")
                        Slider(value: $viewModel.filters.minCompatibilityScore, in: 0.0...1.0)
                    }
                }
                
                Section {
                    Button("Reset to Defaults") {
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.purple)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        Task {
                            await viewModel.applyFilters()
                            showFilters = false
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showFilters = false
                    }
                }
            }
        }
    }
    
    // MARK: - Statistics Sheet
    
    private var statisticsSheet: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Stats cards
                VStack(spacing: 20) {
                    statCard(
                        title: "Today's Matches",
                        value: "\(viewModel.todayMatches)",
                        icon: "heart.circle.fill",
                        color: .pink
                    )
                    
                    HStack(spacing: 20) {
                        statCard(
                            title: "Likes",
                            value: "\(viewModel.totalLikes)",
                            icon: "hand.thumbsup.fill",
                            color: .green
                        )
                        
                        statCard(
                            title: "Passes",
                            value: "\(viewModel.totalPasses)",
                            icon: "hand.thumbsdown.fill",
                            color: .red
                        )
                    }
                    
                    statCard(
                        title: "Remaining",
                        value: "\(viewModel.recommendations.count)",
                        icon: "person.2.fill",
                        color: .purple
                    )
                }
                .padding()
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showStatistics = false
                    }
                }
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Match Celebration
    
    private var matchCelebrationOverlay: some View {
        Group {
            if showMatchCelebration {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Text("🎉")
                            .font(.system(size: 100))
                        
                        Text("It's a Match!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("You both liked each other")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showMatchCelebration = false
                        }) {
                            Text("Keep Swiping")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    StudyBuddyRecommendationView()
        .environmentObject(AuthenticationViewModel())
}
