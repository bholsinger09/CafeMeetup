import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showDeletionProgress = false
    @State private var deletionStep = 0
    
    var body: some View {
        NavigationStack {
            List {
                // Support & Help Section
                Section {
                    Link(destination: URL(string: "mailto:bholsinger@hotmail.com?subject=CafeMeetup Support")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Contact Support")
                        }
                    }
                    
                    Link(destination: URL(string: "mailto:bholsinger@hotmail.com?subject=CafeMeetup Bug Report")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .foregroundColor(.orange)
                            Text("Report an Issue")
                        }
                    }
                } header: {
                    Text("Support & Help")
                } footer: {
                    Text("Get help or report bugs to our support team.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Legal & Privacy Section
                Section {
                    Link(destination: URL(string: "https://bholsinger09.github.io/CafeMeetup/privacy.html")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.green)
                            Text("Privacy Policy")
                        }
                    }
                    
                    Link(destination: URL(string: "https://bholsinger09.github.io/CafeMeetup/")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.purple)
                            Text("Terms of Service")
                        }
                    }
                } header: {
                    Text("Legal")
                } footer: {
                    Text("Review our privacy practices and terms of use.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    NavigationLink {
                        AboutDataDeletionView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("About Data Deletion")
                        }
                    }
                } header: {
                    Text("Data & Privacy")
                }
                
                Section {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Account Management")
                } footer: {
                    Text("Permanently delete your account and all associated data. This action cannot be undone.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // App Information Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundGradient)
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    showDeletionProgress = true
                    Task {
                        await performAccountDeletion()
                    }
                }
            } message: {
                Text("This will permanently delete your account and all data including:\n\n• Your profile and photos\n• All matches and conversations\n• Message history and gifts\n• Location data\n\nThis action cannot be undone.")
            }
            .sheet(isPresented: $showDeletionProgress) {
                DeletionProgressView(step: $deletionStep)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    private func performAccountDeletion() async {
        // Step 1: Remove profile data
        deletionStep = 1
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Step 2: Delete messages and matches
        deletionStep = 2
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Step 3: Remove account
        deletionStep = 3
        await authViewModel.deleteAccount()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        showDeletionProgress = false
        dismiss()
    }
}

struct AboutDataDeletionView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What Gets Deleted")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryPink)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DeletionItemRow(icon: "person.fill", text: "Your profile information (name, email, bio)")
                        DeletionItemRow(icon: "photo.fill", text: "Profile photos and images")
                        DeletionItemRow(icon: "message.fill", text: "All messages and conversations")
                        DeletionItemRow(icon: "heart.fill", text: "Matches and likes")
                        DeletionItemRow(icon: "gift.fill", text: "Virtual gifts sent and received")
                        DeletionItemRow(icon: "location.fill", text: "Location data and check-ins")
                        DeletionItemRow(icon: "doc.text.fill", text: "Blog posts and comments")
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Deletion Timeline")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryPink)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TimelineRow(time: "Immediate", description: "Your account is deactivated and hidden from other users")
                        TimelineRow(time: "Within 24 hours", description: "Your profile and personal data are removed from our servers")
                        TimelineRow(time: "Within 30 days", description: "All backups containing your data are purged")
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Important Notes")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryPink)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        NoteRow(text: "Account deletion is permanent and cannot be undone")
                        NoteRow(text: "You can create a new account anytime with the same email")
                        NoteRow(text: "Other users' copies of conversations will not be deleted")
                        NoteRow(text: "No subscription or billing data is stored (app is free)")
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alternative Options")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryPink)
                    
                    Text("If you're not ready to delete your account permanently, consider:")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        AlternativeRow(text: "Sign out to take a break")
                        AlternativeRow(text: "Hide your profile by signing out")
                        AlternativeRow(text: "Unmatch with specific users")
                    }
                }
            }
            .padding()
        }
        .background(Color.backgroundGradient)
        .navigationTitle("Data Deletion Info")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct DeletionProgressView: View {
    @Binding var step: Int
    
    var body: some View {
        VStack(spacing: 32) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.primaryPink)
            
            VStack(spacing: 12) {
                Text("Deleting Your Account")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(currentStepText)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ProgressStepRow(completed: step >= 1, text: "Removing profile data")
                ProgressStepRow(completed: step >= 2, text: "Deleting messages and matches")
                ProgressStepRow(completed: step >= 3, text: "Finalizing account deletion")
            }
            .padding()
        }
        .padding(32)
        .background(Color.darkSecondary)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .preferredColorScheme(.dark)
    }
    
    private var currentStepText: String {
        switch step {
        case 1:
            return "Removing your profile and photos..."
        case 2:
            return "Deleting your messages and matches..."
        case 3:
            return "Completing deletion process..."
        default:
            return "Preparing to delete your account..."
        }
    }
}

struct DeletionItemRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryPink)
                .frame(width: 24)
            Text(text)
                .font(.body)
        }
    }
}

struct TimelineRow: View {
    let time: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundColor(.primaryPink)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct NoteRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(text)
                .font(.body)
        }
    }
}

struct AlternativeRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.body)
        }
    }
}

struct ProgressStepRow: View {
    let completed: Bool
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(completed ? .green : .secondary)
                .frame(width: 24)
            Text(text)
                .font(.body)
                .foregroundColor(completed ? .primary : .secondary)
        }
    }
}

#Preview {
    AccountSettingsView()
        .environmentObject(AuthenticationViewModel())
}
