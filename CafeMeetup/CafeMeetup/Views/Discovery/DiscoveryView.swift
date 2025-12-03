import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var discoveryViewModel = DiscoveryViewModel()
    @State private var offset = CGSize.zero
    @State private var color: Color = .white
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    if discoveryViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else if let currentUser = discoveryViewModel.currentUser {
                        // Card Stack
                        ZStack {
                            // Show next 2 cards in background for depth
                            ForEach(0..<min(3, discoveryViewModel.potentialMatches.count - discoveryViewModel.currentUserIndex), id: \.self) { index in
                                let user = discoveryViewModel.potentialMatches[discoveryViewModel.currentUserIndex + index]
                                
                                if index == 0 {
                                    ProfileCard(user: user, offset: offset, color: color)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    offset = gesture.translation
                                                    withAnimation {
                                                        if offset.width > 0 {
                                                            color = .green
                                                        } else {
                                                            color = .red
                                                        }
                                                    }
                                                }
                                                .onEnded { _ in
                                                    withAnimation {
                                                        swipeCard()
                                                    }
                                                }
                                        )
                                } else {
                                    ProfileCard(user: user, offset: .zero, color: .white)
                                        .scaleEffect(1 - CGFloat(index) * 0.05)
                                        .offset(y: CGFloat(index) * 10)
                                }
                            }
                        }
                        .padding()
                        
                        // Action Buttons
                        HStack(spacing: 50) {
                            // Pass Button
                            Button {
                                withAnimation {
                                    passUser()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 70)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.7), Color.red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: Color.red.opacity(0.3), radius: 8)
                            }
                            
                            // Like Button
                            Button {
                                withAnimation {
                                    likeUser()
                                }
                            } label: {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 70)
                                    .background(Color.accentGradient)
                                    .clipShape(Circle())
                                    .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                            }
                        }
                        .padding(.bottom, 30)
                    } else {
                        // No more users
                        VStack(spacing: 20) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No more people nearby")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Check back later for new matches!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                Task {
                                    await loadUsers()
                                }
                            } label: {
                                Text("Reload")
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.accentGradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Discover")
            .preferredColorScheme(.dark)
            .task {
                await loadUsers()
            }
            .overlay {
                if discoveryViewModel.showMatchPopup, let matchedUser = discoveryViewModel.matchedUser {
                    MatchPopupView(matchedUser: matchedUser) {
                        discoveryViewModel.showMatchPopup = false
                    }
                }
            }
        }
    }
    
    private func swipeCard() {
        if abs(offset.width) > 100 {
            if offset.width > 0 {
                likeUser()
            } else {
                passUser()
            }
        }
        offset = .zero
        color = .white
    }
    
    private func likeUser() {
        guard let currentUser = discoveryViewModel.currentUser,
              let authUser = authViewModel.currentUser else { return }
        
        Task {
            await discoveryViewModel.likeUser(currentUserId: authUser.id, likedUser: currentUser)
        }
    }
    
    private func passUser() {
        discoveryViewModel.passUser()
    }
    
    private func loadUsers() async {
        guard let authUser = authViewModel.currentUser else { return }
        await discoveryViewModel.loadPotentialMatches(
            currentUserId: authUser.id,
            currentUserCity: authUser.city,
            currentUserState: authUser.state
        )
    }
}

struct ProfileCard: View {
    let user: User
    let offset: CGSize
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            // Profile Image
            ZStack {
                if let profileImageURL = user.profileImageURL,
                   let uiImage = UIImage.fromBase64String(profileImageURL) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 450)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.primaryGradient)
                    
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text(user.fullName.prefix(1))
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .frame(height: 450)
            
            // User Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(user.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if let gender = user.gender, !gender.isEmpty {
                        Text(gender)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    Label(user.college, systemImage: "building.2.fill")
                        .font(.subheadline)
                    
                    if let relationshipStatus = user.relationshipStatus, !relationshipStatus.isEmpty {
                        Label(relationshipStatus, systemImage: "heart.fill")
                            .font(.subheadline)
                    }
                }
                .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("\(user.city), \(user.state)", systemImage: "location.fill")
                    Label(user.favoriteCoffee, systemImage: "cup.and.saucer.fill")
                }
                .font(.subheadline)
                .foregroundColor(.primaryPink)
                
                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .padding(.top, 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.darkSecondary)
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.5), lineWidth: 3)
        )
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
    }
}

struct MatchPopupView: View {
    let matchedUser: User
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 30) {
                Text("It's a Match!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primaryPink)
                
                Text("You and \(matchedUser.fullName) liked each other")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 150, height: 150)
                    .overlay(
                        Text(matchedUser.fullName.prefix(1))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.primaryPink.opacity(0.5), radius: 20)
                
                Button {
                    onDismiss()
                } label: {
                    Text("Keep Swiping")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentGradient)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
            }
            .padding(40)
            .background(Color.darkSecondary)
            .cornerRadius(30)
            .shadow(color: Color.primaryPink.opacity(0.3), radius: 20)
            .padding(40)
        }
    }
}

#Preview {
    DiscoveryView()
        .environmentObject(AuthenticationViewModel())
}
