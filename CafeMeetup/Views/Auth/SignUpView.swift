import SwiftUI

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
    @State private var currentStep = 1
    
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
                            .fill(step <= currentStep ? Color.brown : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
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
                    .background(isCurrentStepValid ? Color.brown : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
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
            Text("Account Information")
                .font(.title2)
                .fontWeight(.bold)
            
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
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthenticationViewModel())
    }
}
