import SwiftUI

/// Live Quiz View - Interactive quizzes for group study sessions
struct LiveQuizView: View {
    @ObservedObject var viewModel: LiveQuizViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showCreateQuiz = false
    @State private var selectedAnswer: Int?
    @State private var showResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if let quiz = viewModel.currentQuiz {
                    quizContentView(quiz: quiz)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Live Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.canCreateQuiz {
                        Button(action: { showCreateQuiz = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateQuiz) {
                CreateQuizView(viewModel: viewModel)
            }
        }
    }
    
    @ViewBuilder
    private func quizContentView(quiz: LiveQuiz) -> some View {
        if quiz.currentQuestionIndex < quiz.questions.count {
            currentQuestionView(quiz: quiz)
        } else {
            quizCompletedView(quiz: quiz)
        }
    }
    
    private func currentQuestionView(quiz: LiveQuiz) -> some View {
        let question = quiz.questions[quiz.currentQuestionIndex]
        let hasAnswered = question.answers[viewModel.userId] != nil
        
        return ScrollView {
            VStack(spacing: 24) {
                // Progress
                quizProgressView(quiz: quiz)
                
                // Timer (if applicable)
                if let timeLimit = question.timeLimit {
                    timerView(timeLimit: timeLimit, revealed: question.revealedAt)
                }
                
                // Question
                Text(question.question)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        answerOptionView(
                            option: option,
                            index: index,
                            question: question,
                            isSelected: selectedAnswer == index || question.answers[viewModel.userId] == index,
                            hasAnswered: hasAnswered
                        )
                    }
                }
                .padding(.horizontal)
                
                // Submit button
                if !hasAnswered, let selectedAnswer = selectedAnswer {
                    Button(action: { submitAnswer(questionIndex: quiz.currentQuestionIndex, answerIndex: selectedAnswer) }) {
                        Text("Submit Answer")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Results (after answering)
                if hasAnswered || question.revealedAt != nil {
                    questionResultsView(question: question)
                }
                
                // Next question button (host only)
                if viewModel.isHost && hasAnswered {
                    Button(action: { viewModel.nextQuestion() }) {
                        Text("Next Question")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func quizProgressView(quiz: LiveQuiz) -> some View {
        VStack(spacing: 8) {
            Text("Question \(quiz.currentQuestionIndex + 1) of \(quiz.questions.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: Double(quiz.currentQuestionIndex + 1), total: Double(quiz.questions.count))
                .tint(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func timerView(timeLimit: Int, revealed: Date?) -> some View {
        let elapsed = revealed.map { Date().timeIntervalSince($0) } ?? 0
        let remaining = max(0, Double(timeLimit) - elapsed)
        
        return HStack(spacing: 12) {
            Image(systemName: "timer")
                .foregroundColor(remaining < 10 ? .red : .blue)
            
            Text("\(Int(remaining))s")
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundColor(remaining < 10 ? .red : .primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func answerOptionView(option: String, index: Int, question: LiveQuiz.QuizQuestion, isSelected: Bool, hasAnswered: Bool) -> some View {
        let isCorrect = index == question.correctAnswerIndex
        let showCorrect = question.revealedAt != nil || hasAnswered
        
        return Button(action: {
            if !hasAnswered {
                selectedAnswer = index
            }
        }) {
            HStack {
                Text(option)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if showCorrect {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isSelected && !isCorrect {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                showCorrect && isCorrect ? Color.green.opacity(0.2) :
                    showCorrect && isSelected && !isCorrect ? Color.red.opacity(0.2) :
                    isSelected ? Color.blue.opacity(0.1) : Color.white
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        showCorrect && isCorrect ? Color.green :
                            showCorrect && isSelected && !isCorrect ? Color.red :
                            isSelected ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(12)
        }
        .disabled(hasAnswered)
    }
    
    private func questionResultsView(question: LiveQuiz.QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(question.answers.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Answered")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    let correctCount = question.answers.values.filter { $0 == question.correctAnswerIndex }.count
                    
                    Text("\(correctCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Correct")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    let accuracy = question.answers.isEmpty ? 0 :
                        Int(Double(question.answers.values.filter { $0 == question.correctAnswerIndex }.count) / Double(question.answers.count) * 100)
                    
                    Text("\(accuracy)%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func quizCompletedView(quiz: LiveQuiz) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                Text("Quiz Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Leaderboard
                leaderboardView(quiz: quiz)
                
                // Summary stats
                quizSummaryView(quiz: quiz)
            }
            .padding()
        }
    }
    
    private func leaderboardView(quiz: LiveQuiz) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Leaderboard")
                .font(.headline)
            
            let sortedScores = quiz.participantScores.sorted { $0.value > $1.value }
            
            ForEach(Array(sortedScores.enumerated()), id: \.element.key) { index, entry in
                HStack {
                    Text("\(index + 1).")
                        .font(.headline)
                        .frame(width: 30, alignment: .leading)
                    
                    Image(systemName: index == 0 ? "crown.fill" : "person.circle.fill")
                        .foregroundColor(index == 0 ? .yellow : .blue)
                    
                    Text("User \(entry.key.prefix(8))")
                        .font(.body)
                    
                    Spacer()
                    
                    Text("\(entry.value) pts")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(index < 3 ? Color.blue.opacity(0.1) : Color.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func quizSummaryView(quiz: LiveQuiz) -> some View {
        let userScore = quiz.participantScores[viewModel.userId] ?? 0
        let maxScore = quiz.questions.count
        
        return VStack(spacing: 16) {
            Text("Your Score")
                .font(.headline)
            
            Text("\(userScore) / \(maxScore)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
            
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(quiz.participantScores.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Participants")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    let percentage = maxScore > 0 ? Int(Double(userScore) / Double(maxScore) * 100) : 0
                    
                    Text("\(percentage)%")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Active Quiz")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create a quiz to test knowledge with your study group")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if viewModel.canCreateQuiz {
                Button(action: { showCreateQuiz = true }) {
                    Label("Create Quiz", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func submitAnswer(questionIndex: Int, answerIndex: Int) {
        viewModel.submitAnswer(questionIndex: questionIndex, answerIndex: answerIndex)
        selectedAnswer = nil
    }
}

// MARK: - Create Quiz View

struct CreateQuizView: View {
    @ObservedObject var viewModel: LiveQuizViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var questions: [QuestionBuilder] = [QuestionBuilder()]
    
    struct QuestionBuilder {
        var question = ""
        var options = ["", "", "", ""]
        var correctAnswerIndex = 0
        var timeLimit = 30
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Quiz Title") {
                    TextField("Enter quiz title", text: $title)
                }
                
                ForEach(questions.indices, id: \.self) { index in
                    Section("Question \(index + 1)") {
                        TextField("Question", text: $questions[index].question, axis: .vertical)
                            .lineLimit(2...4)
                        
                        ForEach(0..<4) { optionIndex in
                            TextField("Option \(optionIndex + 1)", text: $questions[index].options[optionIndex])
                        }
                        
                        Picker("Correct Answer", selection: $questions[index].correctAnswerIndex) {
                            ForEach(0..<4) { i in
                                Text("Option \(i + 1)").tag(i)
                            }
                        }
                        
                        Stepper("Time Limit: \(questions[index].timeLimit)s", value: $questions[index].timeLimit, in: 10...120, step: 10)
                        
                        if questions.count > 1 {
                            Button(role: .destructive, action: { questions.remove(at: index) }) {
                                Text("Delete Question")
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: { questions.append(QuestionBuilder()) }) {
                        Label("Add Question", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Create Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createQuiz()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && questions.allSatisfy { q in
            !q.question.isEmpty && q.options.allSatisfy { !$0.isEmpty }
        }
    }
    
    private func createQuiz() {
        let quizQuestions = questions.map { q in
            LiveQuiz.QuizQuestion(
                question: q.question,
                options: q.options,
                correctAnswerIndex: q.correctAnswerIndex,
                timeLimit: q.timeLimit
            )
        }
        
        viewModel.createQuiz(title: title, questions: quizQuestions)
        dismiss()
    }
}

// MARK: - ViewModel

class LiveQuizViewModel: ObservableObject {
    @Published var currentQuiz: LiveQuiz?
    
    let studySessionId: String
    let userId: String
    let userName: String
    let isHost: Bool
    
    var canCreateQuiz: Bool {
        isHost && (currentQuiz == nil || currentQuiz?.isActive == false)
    }
    
    private let liveSessionService = LiveSessionService.shared
    
    init(studySessionId: String, userId: String, userName: String, isHost: Bool) {
        self.studySessionId = studySessionId
        self.userId = userId
        self.userName = userName
        self.isHost = isHost
        
        setupRealtimeListeners()
    }
    
    func setupRealtimeListeners() {
        liveSessionService.observeCurrentQuiz(sessionId: studySessionId) { [weak self] quiz in
            DispatchQueue.main.async {
                self?.currentQuiz = quiz
            }
        }
    }
    
    func createQuiz(title: String, questions: [LiveQuiz.QuizQuestion]) {
        let quiz = LiveQuiz(
            studySessionId: studySessionId,
            createdBy: userId,
            createdByName: userName,
            title: title,
            questions: questions
        )
        
        liveSessionService.createQuiz(sessionId: studySessionId, quiz: quiz) { success in
            print("Quiz created: \(success)")
        }
    }
    
    func submitAnswer(questionIndex: Int, answerIndex: Int) {
        guard let quiz = currentQuiz, quiz.isActive else { return }
        
        liveSessionService.submitQuizAnswer(
            sessionId: studySessionId,
            quizId: quiz.id,
            questionIndex: questionIndex,
            userId: userId,
            answerIndex: answerIndex
        ) { success in
            print("Answer submitted: \(success)")
        }
    }
    
    func nextQuestion() {
        guard let quiz = currentQuiz, isHost else { return }
        
        liveSessionService.nextQuizQuestion(sessionId: studySessionId, quizId: quiz.id) { success in
            print("Next question: \(success)")
        }
    }
}

#Preview {
    LiveQuizView(
        viewModel: LiveQuizViewModel(
            studySessionId: "session123",
            userId: "user1",
            userName: "John Doe",
            isHost: true
        )
    )
}
