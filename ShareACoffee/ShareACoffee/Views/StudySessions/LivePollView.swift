import SwiftUI
import Charts

/// Live Poll View - Interactive voting during study sessions
struct LivePollView: View {
    @ObservedObject var viewModel: LivePollViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showCreatePoll = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if let currentPoll = viewModel.currentPoll {
                    pollContentView(poll: currentPoll)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Live Poll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.canCreatePoll {
                        Button(action: { showCreatePoll = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreatePoll) {
                CreatePollView(viewModel: viewModel)
            }
        }
    }
    
    @ViewBuilder
    private func pollContentView(poll: LivePoll) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Poll header
                pollHeaderView(poll: poll)
                
                // Question
                Text(poll.question)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Options
                VStack(spacing: 12) {
                    ForEach(Array(poll.options.enumerated()), id: \.element.id) { index, option in
                        pollOptionView(
                            option: option,
                            index: index,
                            totalVotes: poll.votes.count,
                            isSelected: viewModel.userVote == index,
                            poll: poll
                        )
                    }
                }
                .padding(.horizontal)
                
                // Results visualization
                if poll.votes.count > 0 {
                    pollResultsChart(poll: poll)
                }
                
                // Voter list (if not anonymous)
                if !poll.isAnonymous {
                    voterListView(poll: poll)
                }
                
                // Actions
                if poll.isActive && viewModel.isHost {
                    Button(action: { viewModel.closePoll() }) {
                        Text("Close Poll")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
    
    private func pollHeaderView(poll: LivePoll) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Created by \(poll.createdByName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: poll.isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(poll.isActive ? .green : .red)
                    
                    Text(poll.isActive ? "Active" : "Closed")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(poll.votes.count) votes")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                if poll.isAnonymous {
                    Label("Anonymous", systemImage: "eye.slash.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func pollOptionView(option: LivePoll.PollOption, index: Int, totalVotes: Int, isSelected: Bool, poll: LivePoll) -> some View {
        let percentage = totalVotes > 0 ? Double(option.voteCount) / Double(totalVotes) : 0.0
        
        return Button(action: {
            if poll.isActive {
                viewModel.vote(optionIndex: index)
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.text)
                        .font(.body)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if totalVotes > 0 {
                        Text("\(option.voteCount) votes · \(Int(percentage * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                ZStack(alignment: .leading) {
                    Color.white
                    
                    if totalVotes > 0 {
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: geometry.size.width * percentage)
                        }
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .disabled(!poll.isActive)
    }
    
    @ViewBuilder
    private func pollResultsChart(poll: LivePoll) -> some View {
        if #available(iOS 16.0, *) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Results")
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(poll.options) { option in
                        BarMark(
                            x: .value("Votes", option.voteCount),
                            y: .value("Option", option.text)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: CGFloat(poll.options.count * 50))
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private func voterListView(poll: LivePoll) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Voters")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(Array(poll.votes.keys), id: \.self) { userId in
                    if let optionIndex = poll.votes[userId],
                       optionIndex < poll.options.count {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text("User \(userId.prefix(8))")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(poll.options[optionIndex].text)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Active Poll")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create a poll to get quick feedback from your study group")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if viewModel.canCreatePoll {
                Button(action: { showCreatePoll = true }) {
                    Label("Create Poll", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Create Poll View

struct CreatePollView: View {
    @ObservedObject var viewModel: LivePollViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var question = ""
    @State private var options = ["", ""]
    @State private var isAnonymous = false
    @State private var allowMultipleVotes = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Question") {
                    TextField("What's your question?", text: $question, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Options") {
                    ForEach(options.indices, id: \.self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: $options[index])
                            
                            if options.count > 2 {
                                Button(action: { options.remove(at: index) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    if options.count < 6 {
                        Button(action: { options.append("") }) {
                            Label("Add Option", systemImage: "plus.circle.fill")
                        }
                    }
                }
                
                Section("Settings") {
                    Toggle("Anonymous Voting", isOn: $isAnonymous)
                    Toggle("Allow Multiple Votes", isOn: $allowMultipleVotes)
                }
            }
            .navigationTitle("Create Poll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createPoll()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 2
    }
    
    private func createPoll() {
        let validOptions = options
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { LivePoll.PollOption(text: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        
        viewModel.createPoll(
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            options: validOptions,
            isAnonymous: isAnonymous,
            allowMultipleVotes: allowMultipleVotes
        )
        
        dismiss()
    }
}

// MARK: - ViewModel

class LivePollViewModel: ObservableObject {
    @Published var currentPoll: LivePoll?
    @Published var userVote: Int?
    
    let studySessionId: String
    let userId: String
    let userName: String
    let isHost: Bool
    
    var canCreatePoll: Bool {
        isHost && (currentPoll == nil || currentPoll?.isActive == false)
    }
    
    private var liveSessionService: LiveSessionService
    
    init(studySessionId: String, userId: String, userName: String, isHost: Bool) {
        self.studySessionId = studySessionId
        self.userId = userId
        self.userName = userName
        self.isHost = isHost
        self.liveSessionService = LiveSessionService()
        
        setupRealtimeListeners()
    }
    
    func setupRealtimeListeners() {
        liveSessionService.observeCurrentPoll(sessionId: studySessionId) { [weak self] poll in
            DispatchQueue.main.async {
                self?.currentPoll = poll
                self?.userVote = poll?.votes[self?.userId ?? ""]
            }
        }
    }
    
    func createPoll(question: String, options: [LivePoll.PollOption], isAnonymous: Bool, allowMultipleVotes: Bool) {
        let poll = LivePoll(
            studySessionId: studySessionId,
            createdBy: userId,
            createdByName: userName,
            question: question,
            options: options,
            isAnonymous: isAnonymous,
            allowMultipleVotes: allowMultipleVotes
        )
        
        liveSessionService.createPoll(sessionId: studySessionId, poll: poll) { success in
            print("Poll created: \(success)")
        }
    }
    
    func vote(optionIndex: Int) {
        guard let poll = currentPoll, poll.isActive else { return }
        
        // Update local state
        userVote = optionIndex
        
        // Submit vote
        liveSessionService.submitPollVote(
            sessionId: studySessionId,
            pollId: poll.id,
            userId: userId,
            optionIndex: optionIndex
        ) { success in
            print("Vote submitted: \(success)")
        }
    }
    
    func closePoll() {
        guard let poll = currentPoll, isHost else { return }
        
        liveSessionService.closePoll(sessionId: studySessionId, pollId: poll.id) { success in
            print("Poll closed: \(success)")
        }
    }
}

#Preview {
    LivePollView(
        viewModel: LivePollViewModel(
            studySessionId: "session123",
            userId: "user1",
            userName: "John Doe",
            isHost: true
        )
    )
}
