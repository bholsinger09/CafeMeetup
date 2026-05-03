import SwiftUI

/// Session Recap View - Displays shareable highlights from a completed study session
/// Users can swipe through different recap cards and export them for social media
struct SessionRecapView: View {
    let recapData: SessionRecapData
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCardIndex = 0
    @State private var showShareSheet = false
    @State private var showSaveConfirmation = false
    @State private var generatedImages: [UIImage] = []
    @State private var isGeneratingImages = false
    @State private var saveSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Card preview area
                    TabView(selection: $selectedCardIndex) {
                        // Summary card (always first)
                        SessionSummaryCard(recapData: recapData)
                            .tag(0)
                        
                        // Pomodoro stats
                        if let pomodoroStats = recapData.pomodoroStats {
                            PomodoroStatsCard(
                                stats: pomodoroStats,
                                sessionInfo: "\(recapData.studySession.courseCode): \(recapData.studySession.studyTopic)",
                                participantCount: recapData.participantCount
                            )
                            .tag(cardIndexFor(.pomodoro))
                        }
                        
                        // Whiteboard stats
                        if let whiteboardStats = recapData.whiteboardStats, whiteboardStats.hasContent {
                            WhiteboardStatsCard(
                                stats: whiteboardStats,
                                sessionInfo: "\(recapData.studySession.courseCode): \(recapData.studySession.studyTopic)"
                            )
                            .tag(cardIndexFor(.whiteboard))
                        }
                        
                        // Quiz results
                        if let quizSummary = recapData.quizSummary {
                            QuizResultsCard(
                                summary: quizSummary,
                                sessionInfo: recapData.studySession.courseCode
                            )
                            .tag(cardIndexFor(.quiz))
                        }
                        
                        // Poll results
                        ForEach(Array(recapData.topPolls.enumerated()), id: \.element.id) { index, poll in
                            PollResultsCard(
                                poll: poll,
                                sessionInfo: recapData.studySession.courseCode
                            )
                            .tag(cardIndexFor(.poll(index)))
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Controls
                    controlsView
                        .padding()
                        .background(Color.black.opacity(0.8))
                }
            }
            .navigationTitle("Session Recap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isGeneratingImages {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showShareSheet) {
                if !generatedImages.isEmpty {
                    ShareSheet(items: generatedImages)
                }
            }
            .overlay {
                if showSaveConfirmation {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSaveConfirmation = false
                        }
                    
                    ImageSaveResult(success: saveSuccess) {
                        showSaveConfirmation = false
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    private var controlsView: some View {
        VStack(spacing: 16) {
            // Card counter
            Text("\(selectedCardIndex + 1) of \(totalCards)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            // Action buttons
            HStack(spacing: 12) {
                // Export all button
                Button(action: exportAllCards) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.title2)
                        
                        Text("Save All")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(12)
                }
                .disabled(isGeneratingImages)
                
                // Share button
                Button(action: shareCards) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.title2)
                        
                        Text("Share")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(12)
                }
                .disabled(isGeneratingImages)
                
                // Save current button
                Button(action: saveCurrentCard) {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .font(.title2)
                        
                        Text("Save This")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple.opacity(0.8))
                    .cornerRadius(12)
                }
                .disabled(isGeneratingImages)
            }
        }
    }
    
    // MARK: - Card Indexing
    
    enum CardType {
        case summary
        case pomodoro
        case whiteboard
        case quiz
        case poll(Int)
    }
    
    private func cardIndexFor(_ type: CardType) -> Int {
        var index = 1 // 0 is always summary
        
        switch type {
        case .summary:
            return 0
        case .pomodoro:
            return index
        case .whiteboard:
            if recapData.pomodoroStats != nil { index += 1 }
            return index
        case .quiz:
            if recapData.pomodoroStats != nil { index += 1 }
            if recapData.whiteboardStats?.hasContent == true { index += 1 }
            return index
        case .poll(let pollIndex):
            if recapData.pomodoroStats != nil { index += 1 }
            if recapData.whiteboardStats?.hasContent == true { index += 1 }
            if recapData.quizSummary != nil { index += 1 }
            return index + pollIndex
        }
    }
    
    private var totalCards: Int {
        var count = 1 // Summary card
        if recapData.pomodoroStats != nil { count += 1 }
        if recapData.whiteboardStats?.hasContent == true { count += 1 }
        if recapData.quizSummary != nil { count += 1 }
        count += recapData.topPolls.count
        return count
    }
    
    // MARK: - Actions
    
    private func exportAllCards() {
        isGeneratingImages = true
        
        Task { @MainActor in
            let images = await generateAllCardImages()
            
            guard !images.isEmpty else {
                isGeneratingImages = false
                saveSuccess = false
                showSaveConfirmation = true
                return
            }
            
            // Save all images to photos
            for image in images {
                ViewRenderer.saveToPhotos(image: image) { success, error in
                    // Handle individual save results if needed
                }
            }
            
            isGeneratingImages = false
            saveSuccess = true
            showSaveConfirmation = true
        }
    }
    
    private func shareCards() {
        isGeneratingImages = true
        
        Task { @MainActor in
            let images = await generateAllCardImages()
            generatedImages = images
            isGeneratingImages = false
            
            guard !images.isEmpty else { return }
            showShareSheet = true
        }
    }
    
    private func saveCurrentCard() {
        isGeneratingImages = true
        
        Task { @MainActor in
            guard let image = await generateCardImage(at: selectedCardIndex) else {
                isGeneratingImages = false
                saveSuccess = false
                showSaveConfirmation = true
                return
            }
            
            ViewRenderer.saveToPhotos(image: image) { success, error in
                Task { @MainActor in
                    isGeneratingImages = false
                    saveSuccess = success
                    showSaveConfirmation = true
                }
            }
        }
    }
    
    // MARK: - Image Generation
    
    private func generateAllCardImages() async -> [UIImage] {
        var images: [UIImage] = []
        
        // Summary card
        if let image = ViewRenderer.renderToSquare(view: SessionSummaryCard(recapData: recapData)) {
            images.append(image)
        }
        
        // Pomodoro stats
        if let pomodoroStats = recapData.pomodoroStats,
           let image = ViewRenderer.renderToSquare(view: PomodoroStatsCard(
               stats: pomodoroStats,
               sessionInfo: "\(recapData.studySession.courseCode): \(recapData.studySession.studyTopic)",
               participantCount: recapData.participantCount
           )) {
            images.append(image)
        }
        
        // Whiteboard stats
        if let whiteboardStats = recapData.whiteboardStats, whiteboardStats.hasContent,
           let image = ViewRenderer.renderToSquare(view: WhiteboardStatsCard(
               stats: whiteboardStats,
               sessionInfo: "\(recapData.studySession.courseCode): \(recapData.studySession.studyTopic)"
           )) {
            images.append(image)
        }
        
        // Quiz results
        if let quizSummary = recapData.quizSummary,
           let image = ViewRenderer.renderToSquare(view: QuizResultsCard(
               summary: quizSummary,
               sessionInfo: recapData.studySession.courseCode
           )) {
            images.append(image)
        }
        
        // Poll results
        for poll in recapData.topPolls {
            if let image = ViewRenderer.renderToSquare(view: PollResultsCard(
                poll: poll,
                sessionInfo: recapData.studySession.courseCode
            )) {
                images.append(image)
            }
        }
        
        return images
    }
    
    private func generateCardImage(at index: Int) async -> UIImage? {
        let sessionInfo = "\(recapData.studySession.courseCode): \(recapData.studySession.studyTopic)"
        
        // Determine which card based on index
        if index == 0 {
            return ViewRenderer.renderToSquare(view: SessionSummaryCard(recapData: recapData))
        }
        
        var currentIndex = 1
        
        // Pomodoro
        if let pomodoroStats = recapData.pomodoroStats {
            if index == currentIndex {
                return ViewRenderer.renderToSquare(view: PomodoroStatsCard(
                    stats: pomodoroStats,
                    sessionInfo: sessionInfo,
                    participantCount: recapData.participantCount
                ))
            }
            currentIndex += 1
        }
        
        // Whiteboard
        if let whiteboardStats = recapData.whiteboardStats, whiteboardStats.hasContent {
            if index == currentIndex {
                return ViewRenderer.renderToSquare(view: WhiteboardStatsCard(
                    stats: whiteboardStats,
                    sessionInfo: sessionInfo
                ))
            }
            currentIndex += 1
        }
        
        // Quiz
        if let quizSummary = recapData.quizSummary {
            if index == currentIndex {
                return ViewRenderer.renderToSquare(view: QuizResultsCard(
                    summary: quizSummary,
                    sessionInfo: recapData.studySession.courseCode
                ))
            }
            currentIndex += 1
        }
        
        // Polls
        let pollIndex = index - currentIndex
        if pollIndex >= 0 && pollIndex < recapData.topPolls.count {
            return ViewRenderer.renderToSquare(view: PollResultsCard(
                poll: recapData.topPolls[pollIndex],
                sessionInfo: recapData.studySession.courseCode
            ))
        }
        
        return nil
    }
}

// MARK: - Preview

#Preview {
    SessionRecapView(recapData: SessionRecapData.sample)
}
