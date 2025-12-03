import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var matchViewModel = MatchViewModel()
    @State private var selectedMatch: Match?
    @State private var selectedUser: User?
    @State private var showChat = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGradient
                    .ignoresSafeArea()
                
                if matchViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if matchViewModel.matches.isEmpty {
                    // No matches yet
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No matches yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Start swiping in the Discover tab to find matches!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(matchViewModel.matches) { match in
                                MatchRow(match: match, currentUserId: authViewModel.currentUser?.id ?? "")
                                    .onTapGesture {
                                        selectedMatch = match
                                        Task {
                                            if let user = await matchViewModel.getMatchedUser(match: match, currentUserId: authViewModel.currentUser?.id ?? "") {
                                                selectedUser = user
                                                showChat = true
                                            }
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Matches")
            .preferredColorScheme(.dark)
            .task {
                if let userId = authViewModel.currentUser?.id {
                    await matchViewModel.fetchMatches(forUserId: userId)
                }
            }
            .sheet(isPresented: $showChat) {
                if let selectedUser = selectedUser {
                    ChatView(otherUser: selectedUser)
                }
            }
        }
    }
}

struct MatchRow: View {
    let match: Match
    let currentUserId: String
    @State private var matchedUser: User?
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Circle
            Circle()
                .fill(Color.primaryGradient)
                .frame(width: 60, height: 60)
                .overlay(
                    Text(matchedUser?.fullName.prefix(1) ?? "?")
                        .font(.title2)
                        .foregroundColor(.white)
                )
                .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(matchedUser?.fullName ?? "Loading...")
                    .font(.headline)
                
                Text(matchedUser?.college ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Matched \(match.matchedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundColor(.primaryPink)
            }
            
            Spacer()
            
            // Unread indicator
            if match.unreadCount > 0 {
                Text("\(match.unreadCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.darkSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
        )
        .task {
            await loadMatchedUser()
        }
    }
    
    private func loadMatchedUser() async {
        let otherUserId = match.otherUserId(currentUserId: currentUserId)
        do {
            matchedUser = try await UserService.shared.fetchUser(id: otherUserId)
        } catch {
            print("Error loading matched user: \(error)")
        }
    }
}

#Preview {
    MatchesView()
        .environmentObject(AuthenticationViewModel())
}
