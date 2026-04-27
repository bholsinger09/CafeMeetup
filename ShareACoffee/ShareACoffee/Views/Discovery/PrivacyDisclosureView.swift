import SwiftUI

/// Privacy disclosure for study buddy recommendations feature
struct PrivacyDisclosureView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                        
                        Text("Your Privacy Matters")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("How we protect your information")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Sample Profiles Section
                    privacySection(
                        icon: "person.2.badge.gearshape",
                        title: "Sample Profiles",
                        description: "Some profiles you see are sample/demo accounts created for demonstration purposes. These are clearly marked with an orange 'Sample Profile' badge.",
                        iconColor: .orange
                    )
                    
                    // Real User Profiles
                    privacySection(
                        icon: "checkmark.shield.fill",
                        title: "Real User Profiles",
                        description: "Actual registered users do not have the 'Sample Profile' badge. All real users have consented to appear in study buddy recommendations.",
                        iconColor: .green
                    )
                    
                    // What We Share
                    privacySection(
                        icon: "eye.slash.fill",
                        title: "What We Share",
                        description: "Only basic profile information is visible: name, college, major, study interests, and approximate location. We never share your email, phone number, or exact address.",
                        iconColor: .blue
                    )
                    
                    // Your Control
                    privacySection(
                        icon: "hand.point.up.left.fill",
                        title: "Your Control",
                        description: "You can control your visibility in Settings. You can also report or block any user at any time. Your safety is our priority.",
                        iconColor: .purple
                    )
                    
                    // Data Security
                    privacySection(
                        icon: "lock.shield.fill",
                        title: "Data Security",
                        description: "All data is encrypted in transit and at rest. We follow industry-standard security practices and comply with applicable privacy regulations.",
                        iconColor: .mint
                    )
                    
                    // Consent
                    privacySection(
                        icon: "hand.thumbsup.fill",
                        title: "Your Consent",
                        description: "By using this feature, you consent to appear in study buddy recommendations for other students at your institution. You can opt out anytime in Settings.",
                        iconColor: .cyan
                    )
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Questions?")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("If you have privacy concerns or questions, please contact us at privacy@studybrew.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Disclaimer
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Important")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Sample profiles are for demonstration only and do not represent real individuals. Exercise caution when connecting with any users online. Always meet in public places for study sessions.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Privacy & Disclosure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
    
    private func privacySection(icon: String, title: String, description: String, iconColor: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    PrivacyDisclosureView()
}
