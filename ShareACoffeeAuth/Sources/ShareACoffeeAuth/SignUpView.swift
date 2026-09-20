import SwiftUI
import ShareACoffeeCore

public struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var city = ""
    @State private var state = ""
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        VStack(spacing: 15) {
                            TextField("Full Name", text: $fullName)
                                .textContentType(.name)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            TextField("City", text: $city)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            TextField("State", text: $state)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Button(action: {
                            guard password == confirmPassword else {
                                errorMessage = "Passwords do not match"
                                return
                            }
                            
                            Task {
                                let newUser = User(
                                    id: UUID().uuidString,
                                    email: email,
                                    fullName: fullName,
                                    college: "",
                                    state: state,
                                    city: city,
                                    location: nil,
                                    profileImageURL: nil,
                                    hasProfileImage: false,
                                    avatarID: nil,
                                    displayName: fullName,
                                    bio: "",
                                    major: nil,
                                    graduationYear: nil,
                                    isTutor: false,
                                    tutorSubjects: nil,
                                    studyHoursThisWeek: 0,
                                    totalStudySessions: 0,
                                    studyStreak: 0,
                                    totalStudyHours: 0,
                                    accountBalance: 0,
                                    theme: .midnight,
                                    createdAt: Date(),
                                    lastActiveAt: Date()
                                )
                                await authViewModel.signUp(
                                    email: email,
                                    password: password,
                                    user: newUser
                                )
                            }
                        }) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            } else {
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                        .background(Color.blue)
                        .cornerRadius(8)
                        .disabled(authViewModel.isLoading)
                        
                        Spacer()
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationViewModel())
}
