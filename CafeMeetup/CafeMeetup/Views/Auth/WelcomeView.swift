import SwiftUI

struct WelcomeView: View {
    @State private var showSignUp = false
    @State private var showSignIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background - Dark mode with soft feminine gradients
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.12, blue: 0.18),
                        Color(red: 0.25, green: 0.15, blue: 0.25),
                        Color(red: 0.20, green: 0.12, blue: 0.22)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App Icon/Logo
                    Image(systemName: "cup.and.saucer.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.65, blue: 0.75), Color(red: 0.75, green: 0.55, blue: 0.70)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.75).opacity(0.3), radius: 20)
                    
                    // Title
                    VStack(spacing: 10) {
                        Text("CafeMeetup")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.95, green: 0.85, blue: 0.90), Color(red: 0.85, green: 0.75, blue: 0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Connect with Christian students over coffee")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.85, green: 0.80, blue: 0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        Button {
                            showSignUp = true
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.75, green: 0.45, blue: 0.65), Color(red: 0.65, green: 0.35, blue: 0.60)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(red: 0.75, green: 0.45, blue: 0.65).opacity(0.4), radius: 10, y: 5)
                        }
                        
                        Button {
                            showSignIn = true
                        } label: {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.85))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.20, green: 0.15, blue: 0.22))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(red: 0.75, green: 0.45, blue: 0.65), Color(red: 0.65, green: 0.35, blue: 0.60)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthenticationViewModel())
}
