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
                    
                    // App Icon/Logo - Black coffee mug with gold lightning bolt
                    ZStack {
                        // Black coffee mug
                        Image(systemName: "cup.and.saucer.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.5), radius: 10)
                        
                        // Gold lightning bolt accent on the mug
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.13))
                            .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.13).opacity(0.8), radius: 6)
                            .offset(x: 25, y: -5)
                    }
                    .frame(height: 140)
                    
                    // Title
                    VStack(spacing: 10) {
                        Text("ShareACoffee")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.95, green: 0.85, blue: 0.90), Color(red: 0.85, green: 0.75, blue: 0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Study groups at coffee shops")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.85, green: 0.80, blue: 0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Value proposition
                    VStack(spacing: 12) {
                        BenefitRow(icon: "book.fill", text: "Join study groups by course code")
                        BenefitRow(icon: "cup.and.saucer.fill", text: "Study at coffee shops near you")
                        BenefitRow(icon: "person.3.fill", text: "Collaborate with 3+ students")
                    }
                    .padding(.horizontal, 32)
                    
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
            .preferredColorScheme(.dark)
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.75))
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.90, green: 0.85, blue: 0.90))
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthenticationViewModel())
}
