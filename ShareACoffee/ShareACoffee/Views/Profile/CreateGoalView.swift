import SwiftUI

// MARK: - Create Goal View
struct CreateGoalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: StudyRoadmapViewModel
    
    @State private var goalTitle = ""
    @State private var goalDescription = ""
    @State private var selectedCategory = GoalCategory.academic
    @State private var targetDate = Date().addingTimeInterval(86400 * 7) // 1 week from now
    @State private var showMilestoneCreator = false
    @State private var milestones: [StudyMilestone] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $goalTitle, prompt: Text("e.g., Pass Calc Midterm 80%"))
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description (optional)", text: $goalDescription, prompt: Text("Add details..."))
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section(header: Text("Timeline")) {
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                }
                
                Section(header: Text("Milestones")) {
                    if milestones.isEmpty {
                        Button(action: { showMilestoneCreator = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Add First Milestone")
                            }
                        }
                    } else {
                        ForEach(milestones.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(milestones[index].title)
                                    .font(.headline)
                                Text(milestones[index].description ?? "")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        Button(action: { showMilestoneCreator = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                                Text("Add Another Milestone")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createGoal()
                    }
                    .disabled(goalTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showMilestoneCreator) {
                AddMilestoneView(
                    milestones: $milestones,
                    nextPosition: milestones.count
                )
            }
        }
    }
    
    private func createGoal() {
        viewModel.createGoal(
            title: goalTitle,
            description: goalDescription.isEmpty ? nil : goalDescription,
            category: selectedCategory,
            targetDate: targetDate,
            milestones: milestones
        )
        dismiss()
    }
}

// MARK: - Add Milestone View
struct AddMilestoneView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var milestones: [StudyMilestone]
    
    @State private var milestoneTitle = ""
    @State private var milestoneDescription = ""
    @State private var milestoneDueDate = Date().addingTimeInterval(86400 * 3)
    @State private var targetMetric = ""
    
    let nextPosition: Int
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Milestone Details")) {
                    TextField("Milestone Title", text: $milestoneTitle, prompt: Text("e.g., Study 2 hours"))
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description (optional)", text: $milestoneDescription)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Target Metric", text: $targetMetric, prompt: Text("e.g., 80%, 2 hours"))
                        .textFieldStyle(.roundedBorder)
                }
                
                Section(header: Text("Due Date")) {
                    DatePicker("Due Date", selection: $milestoneDueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addMilestone()
                    }
                    .disabled(milestoneTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addMilestone() {
        let milestone = StudyMilestone(
            goalId: UUID().uuidString,
            title: milestoneTitle,
            description: milestoneDescription.isEmpty ? nil : milestoneDescription,
            dueDate: milestoneDueDate,
            position: nextPosition,
            targetMetric: targetMetric.isEmpty ? nil : targetMetric
        )
        milestones.append(milestone)
        dismiss()
    }
}

// MARK: - Goal Detail View
struct GoalDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: StudyRoadmapViewModel
    
    let goalId: String
    @State private var showEditMode = false
    @State private var showDeleteConfirmation = false
    @State private var progressSlider: Int = 0
    @State private var showMilestoneAdder = false
    @State private var showEditMilestone = false
    @State private var editingMilestone: StudyMilestone?
    @State private var editingMilestoneIndex: Int?
    @State private var milestoneToEdit: StudyMilestone?
    @State private var showEditMilestoneView = false
    
    init(goal: StudyGoal, viewModel: StudyRoadmapViewModel) {
        self.goalId = goal.id
        self.viewModel = viewModel
        _progressSlider = State(initialValue: goal.currentProgress)
    }
    
    // Get the current goal from the ViewModel to ensure it's always up-to-date
    private var goal: StudyGoal? {
    viewModel.roadmap.goals.first(where: { $0.id == goalId })
    }
    
    var body: some View {
        NavigationStack {
            if let goal = goal {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(goal.category.emoji)
                                    .font(.title)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(goal.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(goal.status.emoji)
                                .font(.title)
                        }
                        
                        if let description = goal.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .onAppear {
                        print("[GoalDetailView] Opened goal: \(goal.title)")
                        print("[GoalDetailView]   Category: \(goal.category.rawValue)")
                        print("[GoalDetailView]   Milestones: \(goal.milestones.count)")
                        for (i, m) in goal.milestones.enumerated() {
                            print("[GoalDetailView]     [\(i)] \(m.title) (completed: \(m.isCompleted))")
                        }
                    }
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Progress")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(progressSlider)%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Progress")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Slider(value: Binding(
                                get: { Double(progressSlider) },
                                set: { progressSlider = Int($0) }
                            ), in: 0...100, step: 5)
                            .tint(.blue)
                        }
                        
                        ProgressView(value: Double(progressSlider) / 100.0)
                            .tint(.blue)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Timeline Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timeline")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Target Date")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                Text(goal.targetDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("Days Remaining")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                Text("\(goal.daysRemaining)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(goal.daysRemaining < 3 ? .red : .green)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Milestones Section
                    if !goal.milestones.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Milestones")
                                    .font(.headline)
                                Spacer()
                                Text("\(goal.milestones.filter { !$0.isCompleted }.count) of \(goal.milestones.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(goal.milestones, id: \.id) { milestone in
                                    MilestoneRowView(
                                        milestone: milestone,
                                        onComplete: {
                                            print("[GoalDetailView] Complete milestone: \(milestone.title)")
                                            viewModel.completeMilestone(milestone)
                                            var updatedGoal = goal
                                            updatedGoal.completedMilestoneIds.insert(milestone.id)
                                            viewModel.updateGoal(updatedGoal)
                                        },
                                        onEdit: {
                                            print("🎯 [GoalDetailView.onEdit] CALLED for milestone: \(milestone.title)")
                                            milestoneToEdit = milestone
                                            editingMilestoneIndex = goal.milestones.firstIndex(where: { $0.id == milestone.id })
                                            print("  Setting milestoneToEdit: \(milestoneToEdit?.title ?? "nil")")
                                            print("  Index: \(editingMilestoneIndex?.description ?? "nil")")
                                            showEditMilestoneView = true
                                        }
                                    )
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Milestones")
                                .font(.headline)
                            Text("No milestones yet")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Add Milestone Button
                    Button(action: { showMilestoneAdder = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Milestone")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    
                    // Status Actions
                    VStack(spacing: 8) {
                        if goal.status != .completed {
                            Button(action: { markComplete() }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Mark as Complete")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        
                        if goal.status == .inProgress {
                            Button(action: { pauseGoal() }) {
                                HStack {
                                    Image(systemName: "pause.circle.fill")
                                    Text("Pause Goal")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash.circle.fill")
                                Text("Delete Goal")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        updateGoal()
                        dismiss()
                    }
                }
            }
            .alert("Delete Goal?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteGoal(goal)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
            }
            .sheet(isPresented: $showMilestoneAdder) {
                AddMilestoneView(
                    milestones: Binding(
                        get: { goal.milestones },
                        set: { newMilestones in
                            var updatedGoal = goal
                            updatedGoal.milestones = newMilestones
                            viewModel.updateGoal(updatedGoal)
                        }
                    ),
                    nextPosition: goal.milestones.count
                )
            }
            .navigationDestination(isPresented: $showEditMilestoneView) {
                editMilestoneDestinationView
            }
            } else {
                Text("Goal not found")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var editMilestoneDestinationView: some View {
        if let milestoneToEdit = milestoneToEdit, let idx = editingMilestoneIndex {
            return AnyView(
                EditMilestoneView(
                    milestone: milestoneToEdit,
                    onSave: { updatedMilestone in
                        print("✅ [EditMilestoneView] Saved milestone: \(updatedMilestone.title)")
                        var updatedGoal = goal
                        updatedGoal?.milestones[idx] = updatedMilestone
                        if let updated = updatedGoal {
                            viewModel.updateGoal(updated)
                        }
                        showEditMilestoneView = false
                        self.milestoneToEdit = nil
                        self.editingMilestoneIndex = nil
                    }
                )
            )
        } else {
            return AnyView(Text("Error loading milestone"))
        }
    }
    
    private func updateGoal() {
        guard var updatedGoal = goal else { return }
        updatedGoal.currentProgress = progressSlider
        viewModel.updateGoal(updatedGoal)
    }
    
    private func markComplete() {
        guard var updatedGoal = goal else { return }
        updatedGoal.status = .completed
        updatedGoal.currentProgress = 100
        viewModel.updateGoal(updatedGoal)
    }
    
    private func pauseGoal() {
        guard var updatedGoal = goal else { return }
        updatedGoal.status = .paused
        viewModel.updateGoal(updatedGoal)
    }
}

// MARK: - Milestone Row View
struct MilestoneRowView: View {
    let milestone: StudyMilestone
    let onComplete: () -> Void
    let onEdit: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status + Title + Date
            HStack(alignment: .top, spacing: 12) {
                // Status circle
                if milestone.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Title - Primary text (black in light mode, white in dark mode)
                    Text(milestone.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .strikethrough(milestone.isCompleted)
                    
                    // Description - Secondary text (gray in both modes)
                    if let description = milestone.description {
                        Text(description)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    // Target metric
                    if let metric = milestone.targetMetric {
                        Text("🎯 \(metric)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Due date
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Due:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(milestone.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.circle.fill")
                        Text("Edit")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.body)
                }
                
                if !milestone.isCompleted {
                    Button(action: onComplete) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Done")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.body)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Edit Milestone View (Full Screen Navigation)
struct EditMilestoneView: View {
    @Environment(\.dismiss) var dismiss
    @State var milestone: StudyMilestone
    let onSave: (StudyMilestone) -> Void
    
    init(milestone: StudyMilestone, onSave: @escaping (StudyMilestone) -> Void) {
        _milestone = State(initialValue: milestone)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with nav bar style
                VStack(spacing: 12) {
                    HStack {
                        Button("Cancel") { dismiss() }
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Edit Milestone")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            print("✅ Save tapped: \(milestone.title)")
                            onSave(milestone)
                            dismiss()
                        }) {
                            Text("Save")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .disabled(milestone.title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(16)
                }
                .background(Color(.systemGray6))
                
                // Form content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Current milestone info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Milestone")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text(milestone.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title *")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("Enter milestone title", text: $milestone.title)
                                .padding(12)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: Binding(
                                get: { milestone.description ?? "" },
                                set: { milestone.description = $0.isEmpty ? nil : $0 }
                            ))
                            .frame(height: 100)
                            .padding(12)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                        }
                        
                        // Target Metric Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Metric")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("e.g., 80%, 2 hours", text: Binding(
                                get: { milestone.targetMetric ?? "" },
                                set: { milestone.targetMetric = $0.isEmpty ? nil : $0 }
                            ))
                            .padding(12)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                        
                        // Due Date Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            DatePicker(
                                "Select Due Date",
                                selection: $milestone.dueDate,
                                displayedComponents: .date
                            )
                            .padding(12)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    CreateGoalView(viewModel: StudyRoadmapViewModel(userId: "preview"))
}
