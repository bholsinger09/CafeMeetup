import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var discoveryViewModel = DiscoveryViewModel()
    @State private var offset = CGSize.zero
    @State private var color: Color = .white
    @State private var cardId = UUID()
    @State private var viewId = UUID()
    
    var body: some View {
        let _ = print("🎨 [DiscoveryView] body being rendered")
        let _ = print("🎨 [DiscoveryView] User: \(authViewModel.currentUser?.email ?? "none")")
        
        return ZStack {
            Color.backgroundGradient
                .ignoresSafeArea()
            
            // Debug: Add border to identify view bounds
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if discoveryViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let currentUser = discoveryViewModel.currentUser {
                        // Card Stack
                        ZStack {
                            // Show next 2 cards in background for depth (reverse order so top card is on top)
                            ForEach((0..<min(3, discoveryViewModel.potentialMatches.count - discoveryViewModel.currentUserIndex)).reversed(), id: \.self) { index in
                                let user = discoveryViewModel.potentialMatches[discoveryViewModel.currentUserIndex + index]
                                
                                if index == 0 {
                                    ProfileCard(user: user, offset: offset, color: color)
                                        .rotationEffect(.degrees(Double(offset.width / 20)))
                                        .id(cardId)
                                        .zIndex(1)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    offset = gesture.translation
                                                    withAnimation(.spring(response: 0.3)) {
                                                        if offset.width > 0 {
                                                            color = .green
                                                        } else {
                                                            color = .red
                                                        }
                                                    }
                                                }
                                                .onEnded { _ in
                                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                                        swipeCard()
                                                    }
                                                }
                                        )
                                } else {
                                    ProfileCard(user: user, offset: .zero, color: .white)
                                        .scaleEffect(1 - CGFloat(index) * 0.05)
                                        .offset(y: CGFloat(index) * 10)
                                        .zIndex(0)
                                }
                            }
                        }
                        .frame(
                            width: geometry.size.width - 32,
                            height: geometry.size.height * 0.80
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 5)
                        
                        Spacer(minLength: 5)
                        
                        // Action Buttons
                        HStack(spacing: 50) {
                            // Pass Button (X)
                            Button {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                    offset = CGSize(width: -500, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    passUser()
                                    offset = .zero
                                    color = .white
                                    cardId = UUID()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 30, weight: .bold))
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
                                    .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 4)
                            }
                            .scaleEffect(offset.width < -50 ? 1.1 : 1.0)
                            
                            // Like Button (Heart)
                            Button {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                    offset = CGSize(width: 500, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    likeUser()
                                    offset = .zero
                                    color = .white
                                    cardId = UUID()
                                }
                            } label: {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 70)
                                    .background(Color.accentGradient)
                                    .clipShape(Circle())
                                    .shadow(color: Color.primaryPink.opacity(0.4), radius: 10, x: 0, y: 4)
                            }
                            .scaleEffect(offset.width > 50 ? 1.1 : 1.0)
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
        }
        .preferredColorScheme(.dark)
        .task {
            await loadUsers()
        }
        .onAppear {
            print("\n" + String(repeating: "=", count: 60))
            print("🔍 [DiscoveryView] onAppear called")
            print("🔍 [DiscoveryView] ViewID: \(viewId)")
            print("🔍 [DiscoveryView] Auth state: \(authViewModel.isAuthenticated)")
            print("🔍 [DiscoveryView] Current user: \(authViewModel.currentUser?.fullName ?? "nil")")
            print("🔍 [DiscoveryView] Potential matches count: \(discoveryViewModel.potentialMatches.count)")
            print("🔍 [DiscoveryView] Current index: \(discoveryViewModel.currentUserIndex)")
            print("🔍 [DiscoveryView] ViewModel instance: \(ObjectIdentifier(discoveryViewModel))")
            print(String(repeating: "=", count: 60) + "\n")
            
            // Reset state when view appears
            offset = .zero
            color = .white
            cardId = UUID()
            viewId = UUID()
            
            print("✅ [DiscoveryView] State reset complete\n")
        }
        .onDisappear {
            print("\n👋 [DiscoveryView] onDisappear called - ViewID: \(viewId)\n")
        }
        .overlay {
            if discoveryViewModel.showMatchPopup, let matchedUser = discoveryViewModel.matchedUser {
                MatchPopupView(matchedUser: matchedUser) {
                    discoveryViewModel.showMatchPopup = false
                }
            }
        }
    }
    
    private func swipeCard() {
        let swipeThreshold: CGFloat = 100
        
        print("👆 [DiscoveryView] swipeCard called - offset: \(offset.width)")
        
        if abs(offset.width) > swipeThreshold {
            print("✅ [DiscoveryView] Swipe threshold exceeded (\(abs(offset.width)) > \(swipeThreshold))")
            // Animate card off screen
            let direction: CGFloat = offset.width > 0 ? 1 : -1
            print("➡️ [DiscoveryView] Swipe direction: \(direction > 0 ? "RIGHT (like)" : "LEFT (pass)")")
            
            withAnimation(.easeOut(duration: 0.3)) {
                offset = CGSize(width: direction * 500, height: 0)
            }
            
            // Perform action and reset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if direction > 0 {
                    print("💖 [DiscoveryView] Calling likeUser() after swipe")
                    likeUser()
                } else {
                    print("❌ [DiscoveryView] Calling passUser() after swipe")
                    passUser()
                }
                
                // Reset for next card
                offset = .zero
                color = .white
                cardId = UUID()
            }
        } else {
            print("⬅️ [DiscoveryView] Swipe too short (\(abs(offset.width)) <= \(swipeThreshold)), snapping back")
            // Snap back if didn't swipe far enough
            offset = .zero
            color = .white
        }
    }
    
    private func likeUser() {
        guard let currentUser = discoveryViewModel.currentUser,
              let authUser = authViewModel.currentUser else {
            print("❌ [DiscoveryView] likeUser failed - missing user data")
            return
        }
        
        print("💖 [DiscoveryView] Liking user: \(currentUser.fullName) (\(currentUser.id))")
        print("💖 [DiscoveryView] Current user: \(authUser.fullName) (\(authUser.id))")
        
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
                        .frame(maxHeight: .infinity)
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
                
                // Like indicator (right swipe)
                if offset.width > 50 {
                    VStack {
                        HStack {
                            Spacer()
                            Text("LIKE")
                                .font(.system(size: 50, weight: .black))
                                .foregroundColor(.green)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.green, lineWidth: 5)
                                        .padding(8)
                                )
                                .rotationEffect(.degrees(-20))
                                .padding()
                        }
                        Spacer()
                    }
                    .opacity(min(Double(offset.width / 100), 1.0))
                }
                
                // Pass indicator (left swipe)
                if offset.width < -50 {
                    VStack {
                        HStack {
                            Text("NOPE")
                                .font(.system(size: 50, weight: .black))
                                .foregroundColor(.red)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red, lineWidth: 5)
                                        .padding(8)
                                )
                                .rotationEffect(.degrees(20))
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }
                    .opacity(min(Double(-offset.width / 100), 1.0))
                }
            }
            .frame(maxHeight: .infinity)
            
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
