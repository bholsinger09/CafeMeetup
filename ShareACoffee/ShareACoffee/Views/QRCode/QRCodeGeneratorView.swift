import SwiftUI

/// QR Code Generator View - Display and share QR codes for study sessions
struct QRCodeGeneratorView: View {
    let studySession: StudySession
    let userId: String
    
    @State private var qrCodeImage: UIImage?
    @State private var showShareSheet = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Share Your Session")
                                .font(.title2.bold())
                            
                            Text("Others can scan this code to join")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // QR Code Display
                        if let qrCodeImage = qrCodeImage {
                            VStack(spacing: 16) {
                                Image(uiImage: qrCodeImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 280, height: 280)
                                    .padding(20)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                VStack(spacing: 4) {
                                    Text("Valid for 24 hours")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Session ID: \(studySession.id.prefix(8))...")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .monospaced()
                                }
                            }
                        } else {
                            ProgressView("Generating QR Code...")
                                .frame(height: 280)
                        }
                        
                        // Session Info Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(studySession.courseCode)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(studySession.studyTopic)
                                        .font(.headline)
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "cup.and.saucer.fill")
                                    .foregroundColor(.brown)
                                Text(studySession.cafeName)
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.green)
                                Text(studySession.scheduledDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.purple)
                                Text("\(studySession.attendeeIds.count)/\(studySession.maxAttendees) joined")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: { showShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share QR Code")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: { saveToPhotos() }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Save to Photos")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                            
                            Button(action: { copySessionLink() }) {
                                HStack {
                                    Image(systemName: "link")
                                    Text("Copy Session Link")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to use:")
                                .font(.headline)
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "1.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Share this QR code with students who want to join")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "2.circle.fill")
                                    .foregroundColor(.blue)
                                Text("They scan it using the Scan QR button in the app")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "3.circle.fill")
                                    .foregroundColor(.blue)
                                Text("They'll instantly join your study session!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Session QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let qrCodeImage = qrCodeImage {
                    ShareSheet(items: [qrCodeImage, shareText()])
                }
            }
        }
        .onAppear {
            generateQRCode()
        }
    }
    
    // MARK: - Actions
    
    private func generateQRCode() {
        qrCodeImage = QRCodeService.shared.generateStudySessionQRCode(
            sessionId: studySession.id,
            sessionName: "\(studySession.courseCode): \(studySession.studyTopic)",
            cafeName: studySession.cafeName,
            hostName: studySession.hostName
        )
    }
    
    private func saveToPhotos() {
        guard let qrCodeImage = qrCodeImage else { return }
        UIImageWriteToSavedPhotosAlbum(qrCodeImage, nil, nil, nil)
        
        // Show success feedback (you can add a toast/alert here)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func copySessionLink() {
        let sessionLink = "studybrew://session/\(studySession.id)"
        UIPasteboard.general.string = sessionLink
        
        // Show success feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func shareText() -> String {
        """
        Join my study session!
        
        📚 \(studySession.courseCode): \(studySession.studyTopic)
        ☕️ \(studySession.cafeName)
        📅 \(studySession.scheduledDate.formatted(date: .abbreviated, time: .shortened))
        
        Scan the QR code or use this link:
        studybrew://session/\(studySession.id)
        """
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
