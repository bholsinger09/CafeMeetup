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
    @State private var address = ""
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
        ZStack {
            Color.backgroundGradient
                .ignoresSafeArea()
            
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
                                    address: address.isEmpty ? nil : address,
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
        }
        .navigationTitle("Sign Up")
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
                .foregroundColor(.lightText)
            
            Text("Sign up with Apple for a fast, private way to create your account.")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            // Sign up with Apple - Primary option
            SignInWithAppleButton(
                onRequest: { request in
                    print("🍎 [SignUp] SignInWithAppleButton onRequest called")
                    print("🍎 [SignUp] Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
                    print("🍎 [SignUp] Team ID: \(Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as? String ?? "unknown")")
                    request.requestedScopes = [.fullName, .email]
                    print("🍎 [SignUp] Requested scopes: \(request.requestedScopes ?? [])")
                },
                onCompletion: { result in
                    print("🍎 [SignUp] SignInWithAppleButton onCompletion called")
                    print("🍎 [SignUp] Result type: \(type(of: result))")
                    
                    switch result {
                    case .success(let authorization):
                        print("✅ [SignUp] Apple Sign In successful")
                        print("✅ [SignUp] Authorization type: \(type(of: authorization))")
                        print("✅ [SignUp] Credential type: \(type(of: authorization.credential))")
                        handleAppleSignUp(authorization: authorization)
                    case .failure(let error):
                        print("❌ [SignUp] Apple Sign In failed")
                        print("❌ [SignUp] Error: \(error)")
                        print("❌ [SignUp] Error code: \((error as NSError).code)")
                        print("❌ [SignUp] Error domain: \((error as NSError).domain)")
                        print("❌ [SignUp] Error description: \(error.localizedDescription)")
                        print("❌ [SignUp] Error userInfo: \((error as NSError).userInfo)")
                        
                        let errorCode = (error as NSError).code
                        
                        // Handle different error codes
                        if errorCode == 1001 {
                            // User cancelled
                            print("ℹ️ [SignUp] User cancelled - not showing error")
                        } else if errorCode == 1000 {
                            // Configuration error
                            print("❌ [SignUp] Configuration error - Sign in with Apple not properly set up")
                            errorMessage = "Sign in with Apple is not configured for this app yet. Please use email/password sign up for now.\n\n(Developer: Enable Sign in with Apple capability in Apple Developer Portal for bundle ID: com.holsinger.cafe)"
                            showError = true
                        } else {
                            // Other errors
                            errorMessage = "Sign in with Apple failed: \(error.localizedDescription)"
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
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
            
            SecureField("Password (min 6 characters)", text: $password)
                .textContentType(.newPassword)
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textContentType(.newPassword)
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
            
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
                .foregroundColor(.lightText)
            
            TextField("Full Name", text: $fullName)
                .textContentType(.name)
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
            
            TextField("College/University", text: $college)
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var locationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Location")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.lightText)
            
            // State Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("State")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Select State", selection: $state) {
                    Text("Select State").tag("")
                    ForEach(LocationData.states, id: \.self) { stateName in
                        Text(stateName).tag(stateName)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(Color.darkSecondary)
                .cornerRadius(8)
                .onChange(of: state) { oldValue, newValue in
                    // Reset city when state changes
                    if oldValue != newValue {
                        city = ""
                    }
                }
            }
            
            // City Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("City")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Select City", selection: $city) {
                    Text("Select City").tag("")
                    ForEach(LocationData.cities(for: state), id: \.self) { cityName in
                        Text(cityName).tag(cityName)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(Color.darkSecondary)
                .cornerRadius(8)
                .disabled(state.isEmpty)
            }
            
            if state.isEmpty {
                Text("Please select a state first")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextField("Address (Optional)", text: $address)
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
            
            Text("e.g., 123 Main St")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var coffeePreferencesStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coffee Preferences")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.lightText)
            
            TextField("Favorite Coffee", text: $favoriteCoffee)
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
            
            Text("e.g., Latte, Cappuccino, Cold Brew")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("Favorite Coffee Shop", text: $favoriteCoffeeShop)
                .padding()
                .background(Color.darkSecondary)
                .foregroundColor(.lightText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                )
            
            Text("e.g., Starbucks, Local Café")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func handleAppleSignUp(authorization: ASAuthorization) {
        print("🍎 [SignUp] handleAppleSignUp called")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ [SignUp] Failed to get appleIDCredential")
            return
        }
        
        isUsingAppleSignIn = true
        let userID = appleIDCredential.user
        let appleEmail = appleIDCredential.email ?? "\(userID)@privaterelay.appleid.com"
        let givenName = appleIDCredential.fullName?.givenName ?? ""
        let familyName = appleIDCredential.fullName?.familyName ?? ""
        let appleFullName = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
        
        print("🍎 [SignUp] User ID: \(userID)")
        print("🍎 [SignUp] Email: \(appleEmail)")
        print("🍎 [SignUp] Full Name: \(appleFullName)")
        print("🍎 [SignUp] Given Name: \(givenName)")
        print("🍎 [SignUp] Family Name: \(familyName)")
        
        // Pre-fill form with Apple ID info
        email = appleEmail
        password = userID
        confirmPassword = userID
        if !appleFullName.isEmpty {
            fullName = appleFullName
        }
        
        print("🍎 [SignUp] Calling authViewModel.signInWithApple...")
        
        // Try to sign in with Apple (handles both new and returning users)
        Task {
            await authViewModel.signInWithApple(userID: userID, email: appleEmail, fullName: appleFullName.isEmpty ? nil : appleFullName)
            
            print("🍎 [SignUp] signInWithApple completed")
            print("🍎 [SignUp] isAuthenticated: \(authViewModel.isAuthenticated)")
            print("🍎 [SignUp] errorMessage: \(authViewModel.errorMessage ?? "nil")")
            print("🍎 [SignUp] currentUser: \(authViewModel.currentUser?.email ?? "nil")")
            
            if authViewModel.isAuthenticated {
                print("✅ [SignUp] Authentication successful")
                // Check if profile is complete
                if let user = authViewModel.currentUser,
                   !user.college.isEmpty && !user.state.isEmpty && !user.city.isEmpty && !user.favoriteCoffee.isEmpty {
                    print("✅ [SignUp] Profile complete, dismissing")
                    dismiss()
                } else {
                    print("⏭️ [SignUp] Profile incomplete, moving to step 2")
                    withAnimation {
                        currentStep = 2
                    }
                }
            } else {
                // Sign in failed, show error
                print("❌ [SignUp] Authentication failed")
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
