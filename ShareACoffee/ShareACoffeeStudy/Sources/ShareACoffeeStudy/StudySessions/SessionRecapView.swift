import SwiftUI
import ShareACoffeeCore

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
                        Text("Session Summary Placeholder")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(0)
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
    
    private var totalCards: Int {
        return 1 // Only summary card for now
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
                ViewRenderer.shared.saveToPhotos(image) { success, error in
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
            
            ViewRenderer.shared.saveToPhotos(image) { success, error in
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
        return []
    }
    
    private func generateCardImage(at index: Int) async -> UIImage? {
        return nil
    }
}

// MARK: - Preview

#Preview {
    SessionRecapView(recapData: SessionRecapData.sample)
}
