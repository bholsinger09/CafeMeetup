import SwiftUI

struct StudyRoadmapView: View {
    @StateObject private var viewModel: StudyRoadmapViewModel
    @State private var showCreateGoal = false
    @State private var selectedGoal: StudyGoal?
    @State private var showEditNextMilestone = false
    @State private var nextMilestoneToEdit: StudyMilestone?
    
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: StudyRoadmapViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.05),
                        Color.indigo.opacity(0.08)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Study Roadmap")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Track your goals to success")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        StatusBadge(status: viewModel.syncStatus)
                    }
                    
                    // Overall Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Overall Progress")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(Int(viewModel.overallProgress * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        ProgressView(value: viewModel.overallProgress)
                            .tint(.blue)
                    }
                }
                .padding(16)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Roadmap Visualization
                        RoadmapRoadView(
                            viewModel: viewModel,
                            selectedGoal: $selectedGoal,
                            showEditNextMilestone: $showEditNextMilestone,
                            nextMilestoneToEdit: $nextMilestoneToEdit
                        )
                        .padding(20)
                        
                        Divider()
                            .padding(.vertical, 16)
                        
                        // Goals List
                        if viewModel.totalGoalCount > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Goals")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                    .onAppear {
                                        print("[StudyRoadmapView] Goals loaded: \(viewModel.totalGoalCount)")
                                        for goal in viewModel.roadmap.sortedGoals {
                                            print("[StudyRoadmapView] Goal: '\(goal.title)' | Category: '\(goal.category.rawValue)' | Milestones: \(goal.milestones.count)")
                                        }
                                    }
                                
                                ForEach(viewModel.roadmap.sortedGoals) { goal in
                                    GoalCardView(
                                        goal: goal,
                                        isSelected: selectedGoal?.id == goal.id,
                                        onSelect: { selectedGoal = goal },
                                        onProgressUpdate: { newProgress in
                                            viewModel.updateGoalProgress(goal.id, progress: newProgress)
                                        }
                                    )
                                }
                            }
                            .padding(16)
                        } else {
                            EmptyStateView(
                                icon: "🗺️",
                                title: "No Goals Yet",
                                message: "Create your first goal to start your study roadmap!"
                            )
                            .padding(40)
                        }
                    }
                }
                
                // Action Button
                Button(action: { showCreateGoal = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Goal")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(16)
            }
        }
        }
        .sheet(isPresented: $showCreateGoal) {
            CreateGoalView(viewModel: viewModel)
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal, viewModel: viewModel)
        }
    }
}

// MARK: - Roadmap Road Visualization (Car on a Road)
struct RoadmapRoadView: View {
    @ObservedObject var viewModel: StudyRoadmapViewModel
    @Binding var selectedGoal: StudyGoal?
    @Binding var showEditNextMilestone: Bool
    @Binding var nextMilestoneToEdit: StudyMilestone?
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Road background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 280)
                
                // Road line (simplified)
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(0..<35, id: \.self) { i in
                            if i % 2 == 0 {
                                Rectangle()
                                    .fill(Color.yellow)
                                    .frame(width: 8, height: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 4, height: 2)
                            }
                        }
                    }
                    .frame(height: 2)
                }
                .frame(height: 280)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Start point
                        VStack(spacing: 8) {
                            Image(systemName: "flag.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                            Text("0%\nStart")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                        }
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Dynamic space based on progress
                        Spacer()
                            .frame(maxWidth: .infinity)
                        
                        // Car/Player position - positioned based on progress percentage
                        VStack(spacing: 4) {
                            Text(viewModel.roadmap.theme.carEmoji)
                                .font(.system(size: 28))
                            Text("\(Int(viewModel.carPositionProgress * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .position(x: CGFloat(viewModel.carPositionProgress * 300) + 40)
                        
                        // Dynamic space based on remaining progress
                        Spacer()
                            .frame(maxWidth: .infinity)
                        
                        // End point (Destination)
                        VStack(spacing: 8) {
                            Image(systemName: "flag.2.crossed.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                            Text("100%\nFinish")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(20)
                    .frame(height: 280)
                }
            }
            
            // Next Goal Info
            if let nextGoal = viewModel.nextGoal {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next Milestone")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(nextGoal.title)
                                .font(.headline)
                                .lineLimit(2)
                            
                            if let nextMilestone = nextGoal.nextMilestone {
                                Text("📍 \(nextMilestone.title)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        // Edit button
                        if let nextMilestone = nextGoal.nextMilestone {
                            Button(action: {
                                print("🎯 Edit next milestone: \(nextMilestone.title)")
                                nextMilestoneToEdit = nextMilestone
                                showEditNextMilestone = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Text("\(nextGoal.daysRemaining)d")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(8)
                            .background(
                                nextGoal.daysRemaining < 3 ? Color.red.opacity(0.2) : Color.blue.opacity(0.2)
                            )
                            .foregroundColor(
                                nextGoal.daysRemaining < 3 ? .red : .blue
                            )
                            .cornerRadius(6)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $showEditNextMilestone) {
                    editNextMilestoneDestinationView
                }
            }
        }
    }
    
    private var editNextMilestoneDestinationView: some View {
        if let milestone = nextMilestoneToEdit, let goal = viewModel.nextGoal {
            return AnyView(
                EditMilestoneView(
                    milestone: milestone,
                    onSave: { updatedMilestone in
                        print("✅ [RoadmapRoadView] Saved next milestone: \(updatedMilestone.title)")
                        if let goalIdx = viewModel.roadmap.goals.firstIndex(where: { $0.id == goal.id }),
                           let milestoneIdx = viewModel.roadmap.goals[goalIdx].milestones.firstIndex(where: { $0.id == milestone.id }) {
                            var updatedGoal = viewModel.roadmap.goals[goalIdx]
                            updatedGoal.milestones[milestoneIdx] = updatedMilestone
                            viewModel.updateGoal(updatedGoal)
                        }
                        showEditNextMilestone = false
                        nextMilestoneToEdit = nil
                    }
                )
            )
        } else {
            return AnyView(Text("Error loading milestone"))
        }
    }
}

// MARK: - Roadmap Road View (Nested)

struct GoalCardView: View {
    let goal: StudyGoal
    let isSelected: Bool
    let onSelect: () -> Void
    let onProgressUpdate: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(goal.category.emoji)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(goal.title.isEmpty ? "NO TITLE" : goal.title)
                                .font(.headline)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(goal.title.isEmpty ? .red : .black)
                            if let desc = goal.description {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Text(goal.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(goal.status.emoji)
                        .font(.title3)
                    Text(goal.status.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(goal.currentProgress)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: Double(goal.currentProgress) / 100.0)
                    .tint(.blue)
            }
            
            // Milestones info
            if !goal.milestones.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.circle")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(goal.milestoneSummary)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    if goal.isOverdue {
                        Text("⚠️ Overdue")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    } else {
                        Text("📅 \(goal.daysRemaining)d left")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(12)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
        .border(isSelected ? Color.blue : Color.clear, width: 2)
        .cornerRadius(10)
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: SyncStatus
    
    var body: some View {
        HStack(spacing: 4) {
            if status == .syncing {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
            }
            Text(status.description)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var statusColor: Color {
        switch status {
        case .idle, .synced: return .green
        case .syncing: return .blue
        case .failed: return .red
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 48))
            Text(title)
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    StudyRoadmapView(userId: "preview-user")
}
