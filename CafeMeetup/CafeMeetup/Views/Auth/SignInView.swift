import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    Image(systemName: "cup.and.saucer.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.primaryGradient)
                        .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                        .padding(.top, 40)
                    
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryGradient)
                    
                    // Sign in with Apple - Primary option
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                // Handle successful Sign in with Apple
                                Task {
                                    await handleAppleSignIn(authorization: authorization)
                                }
                            case .failure(let error):
                                // Only show error if it's not a user cancellation
                                if (error as NSError).code != 1001 {
                                    errorMessage = "Sign in with Apple failed. Please try again or use email/password sign in."
                                    showError = true
                                }
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        Text("or")
                            .foregroundColor(.secondaryText)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.darkSecondary)
                            .foregroundColor(.lightText)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                            )
                        
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color.darkSecondary)
                            .foregroundColor(.lightText)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            await authViewModel.signIn(email: email, password: password)
                            
                            if authViewModel.isAuthenticated {
                                dismiss()
                            } else {
                                showError = true
                            }
                        }
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentGradient)
                            .cornerRadius(12)
                            .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .alert("Error", isPresented: $showError) {
            Button("OK") { 
                errorMessage = ""
            }
        } message: {
            Text(!errorMessage.isEmpty ? errorMessage : (authViewModel.errorMessage ?? "An error occurred"))
        }
        .overlay {
            if authViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
    }
    
    private func handleAppleSignIn(authorization: ASAuthorization) async {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        let userID = appleIDCredential.user
        let email = appleIDCredential.email ?? "\(userID)@privaterelay.appleid.com"
        let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        // Sign in with Apple ID using dedicated method
        await authViewModel.signInWithApple(userID: userID, email: email, fullName: fullName.isEmpty ? nil : fullName)
        
        if authViewModel.isAuthenticated {
            dismiss()
        } else {
            errorMessage = authViewModel.errorMessage ?? "Failed to sign in with Apple"
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthenticationViewModel())
    }
}
