import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    
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
            Button("OK") { }
        } message: {
            Text(authViewModel.errorMessage ?? "An error occurred")
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
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthenticationViewModel())
    }
}
