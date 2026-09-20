import SwiftUI
import ShareACoffeeAuth
import AuthenticationServices

public struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var animate = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background with coffee shop vibes
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.15, green: 0.1, blue: 0.08),
                        Color(red: 0.08, green: 0.06, blue: 0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Coffee cup background pattern
                VStack(spacing: 0) {
                    HStack(spacing: 40) {
                        Text("☕")
                            .font(.system(size: 100))
                            .opacity(0.25)
                            .offset(y: animate ? -20 : 0)
                        
                        Text("📚")
                            .font(.system(size: 100))
                            .opacity(0.25)
                            .offset(y: animate ? 20 : 0)
                        
                        Text("🍵")
                            .font(.system(size: 100))
                            .opacity(0.25)
                            .offset(y: animate ? -15 : 0)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                }
                .ignoresSafeArea()
                
                // Overlay to ensure readability
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                    .frame(height: 200)
                    
                    Spacer()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.5)
                        ]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 250)
                }
                .ignoresSafeArea()
                
                // Content
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Share A Coffee")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Study Together, Grow Together")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Text("Find study buddies at your favorite coffee shop")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.6))
                            .padding(.top, 8)
                    }
                    .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: SignInView()) {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.5, blue: 1.0),
                                            Color(red: 0.0, green: 0.4, blue: 0.9)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        
                        // Sign In with Apple Button
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result, authViewModel: authViewModel)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        NavigationLink(destination: SignUpView()) {
                            HStack {
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Color.white.opacity(0.15)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(20)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthenticationViewModel())
}

// MARK: - Apple Sign In Handler

private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, authViewModel: AuthenticationViewModel) {
    switch result {
    case .success(let authorization):
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ Unable to retrieve Apple ID credential")
            return
        }
        
        let userID = appleIDCredential.user
        let email = appleIDCredential.email ?? ""
        let fullName = appleIDCredential.fullName?.givenName ?? appleIDCredential.fullName?.familyName
        
        print("✅ Apple Sign In successful")
        print("  userID: \(userID)")
        print("  email: \(email)")
        print("  fullName: \(fullName ?? "nil")")
        
        // Call the sign in method on auth view model
        Task {
            await authViewModel.signInWithApple(userID: userID, email: email, fullName: fullName)
        }
        
    case .failure(let error):
        print("❌ Apple Sign In failed: \(error.localizedDescription)")
        // Handle specific error cases
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                print("User cancelled Apple Sign In")
            case .failed:
                print("Apple Sign In failed")
            case .invalidResponse:
                print("Invalid response from Apple Sign In")
            case .notHandled:
                print("Apple Sign In request not handled")
            case .notInteractive:
                print("Apple Sign In request not interactive")
            @unknown default:
                print("Unknown Apple Sign In error: \(authError.code)")
            }
        }
    }
}
