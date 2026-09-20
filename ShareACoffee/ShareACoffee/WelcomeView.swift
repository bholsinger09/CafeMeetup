import SwiftUI
import ShareACoffeeAuth
import AuthenticationServices

public struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.12, blue: 0.15),
                        Color(red: 0.08, green: 0.1, blue: 0.13)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Share A Coffee")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Study Together, Grow Together")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: SignInView()) {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    // Sign In with Apple Button
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result, authViewModel: authViewModel)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .cornerRadius(10)
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(20)
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
