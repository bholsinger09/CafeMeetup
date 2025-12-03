import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var college = ""
    @State private var state = ""
    @State private var city = ""
    @State private var favoriteCoffee = ""
    @State private var favoriteCoffeeShop = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var currentStep = 1
    @State private var isUsingAppleSignIn = false
    
    private var isStep1Valid: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6 && password == confirmPassword
    }
    
    private var isStep2Valid: Bool {
        !fullName.isEmpty && !college.isEmpty
    }
    
    private var isStep3Valid: Bool {
        !state.isEmpty && !city.isEmpty
    }
    
    private var isStep4Valid: Bool {
        !favoriteCoffee.isEmpty && !favoriteCoffeeShop.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep ? Color.primaryPink : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .shadow(color: step <= currentStep ? Color.primaryPink.opacity(0.4) : Color.clear, radius: 4)
                    }
                }
                .padding(.top)
                
                // Step content
                switch currentStep {
                case 1:
                    accountInfoStep
                case 2:
                    personalInfoStep
                case 3:
                    locationStep
                case 4:
                    coffeePreferencesStep
                default:
                    EmptyView()
                }
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 1 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    Button(currentStep == 4 ? "Create Account" : "Next") {
                        if currentStep == 4 {
                            Task {
                                await authViewModel.signUp(
                                    email: email,
                                    password: password,
                                    fullName: fullName,
                                    college: college,
                                    state: state,
                                    city: city,
                                    favoriteCoffee: favoriteCoffee,
                                    favoriteCoffeeShop: favoriteCoffeeShop
                                )
                                
                                if authViewModel.isAuthenticated {
                                    dismiss()
                                } else {
                                    showError = true
                                }
                            }
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .disabled(!isCurrentStepValid)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        isCurrentStepValid ? 
                        LinearGradient(
                            colors: [Color(red: 0.75, green: 0.45, blue: 0.65), Color(red: 0.65, green: 0.35, blue: 0.60)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: isCurrentStepValid ? Color(red: 0.75, green: 0.45, blue: 0.65).opacity(0.3) : Color.clear, radius: 8, y: 4)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
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
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 1: return isStep1Valid
        case 2: return isStep2Valid
        case 3: return isStep3Valid
        case 4: return isStep4Valid
        default: return false
        }
    }
    
    private var accountInfoStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Get Started")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Sign up with Apple for a fast, private way to create your account.")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            // Sign up with Apple - Primary option
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAppleSignUp(authorization: authorization)
                    case .failure(let error):
                        // Only show error if it's not a user cancellation
                        if (error as NSError).code != 1001 {
                            errorMessage = "Sign in with Apple failed. Please try again or use email/password sign up."
                            showError = true
                        }
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(12)
            
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
            .padding(.vertical, 8)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password (min 6 characters)", text: $password)
                .textContentType(.newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textContentType(.newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !password.isEmpty && password != confirmPassword {
                Text("Passwords don't match")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var personalInfoStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Full Name", text: $fullName)
                .textContentType(.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("College/University", text: $college)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var locationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Location")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("State", text: $state)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("City", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var coffeePreferencesStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coffee Preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Favorite Coffee", text: $favoriteCoffee)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("e.g., Latte, Cappuccino, Cold Brew")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("Favorite Coffee Shop", text: $favoriteCoffeeShop)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("e.g., Starbucks, Local Café")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func handleAppleSignUp(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        isUsingAppleSignIn = true
        let userID = appleIDCredential.user
        let appleEmail = appleIDCredential.email ?? "\(userID)@privaterelay.appleid.com"
        let givenName = appleIDCredential.fullName?.givenName ?? ""
        let familyName = appleIDCredential.fullName?.familyName ?? ""
        let appleFullName = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
        
        // Pre-fill form with Apple ID info
        email = appleEmail
        password = userID
        confirmPassword = userID
        if !appleFullName.isEmpty {
            fullName = appleFullName
        }
        
        // Try to sign in with Apple (handles both new and returning users)
        Task {
            await authViewModel.signInWithApple(userID: userID, email: appleEmail, fullName: appleFullName.isEmpty ? nil : appleFullName)
            
            if authViewModel.isAuthenticated {
                // Check if profile is complete
                if let user = authViewModel.currentUser,
                   !user.college.isEmpty && !user.state.isEmpty && !user.city.isEmpty && !user.favoriteCoffee.isEmpty {
                    // Profile complete, dismiss
                    dismiss()
                } else {
                    // Profile incomplete, continue to step 2 to collect info
                    withAnimation {
                        currentStep = 2
                    }
                }
            } else {
                // Sign in failed, show error
                errorMessage = authViewModel.errorMessage ?? "Failed to sign up with Apple"
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthenticationViewModel())
    }
}
