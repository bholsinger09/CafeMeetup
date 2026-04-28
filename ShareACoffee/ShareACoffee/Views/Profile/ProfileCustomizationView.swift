import SwiftUI

struct ProfileCustomizationView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showPremiumPaywall = false
    @State private var selectedTheme: AppTheme?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Study Aesthetics")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Customize your study environment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Current Theme Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Theme")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        CurrentThemePreview(theme: themeManager.currentTheme)
                    }
                    .padding(.horizontal)
                    
                    // Theme Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Themes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // Free Themes
                        VStack(spacing: 12) {
                            ForEach(AppTheme.allCases.filter { !$0.isPremium }) { theme in
                                ThemeSelectionCard(
                                    theme: theme,
                                    isSelected: themeManager.currentTheme == theme
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        themeManager.setTheme(theme)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Premium Themes
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Premium Themes", systemImage: "crown.fill")
                                    .font(.headline)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Spacer()
                                
                                if !themeManager.isPremiumUser {
                                    Button("Unlock All") {
                                        showPremiumPaywall = true
                                    }
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            VStack(spacing: 12) {
                                ForEach(AppTheme.allCases.filter { $0.isPremium }) { theme in
                                    ThemeSelectionCard(
                                        theme: theme,
                                        isSelected: themeManager.currentTheme == theme,
                                        isPremium: !themeManager.isPremiumUser
                                    ) {
                                        if themeManager.isPremiumUser {
                                            withAnimation(.spring(response: 0.3)) {
                                                themeManager.setTheme(theme)
                                            }
                                        } else {
                                            showPremiumPaywall = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Tips Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tips")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TipCard(
                            icon: "lightbulb.fill",
                            title: "Match Your Mood",
                            description: "Choose themes that help you focus. Dark themes reduce eye strain during night study sessions."
                        )
                        
                        TipCard(
                            icon: "paintbrush.fill",
                            title: "Express Yourself",
                            description: "Your theme choice appears on your profile, letting study buddies see your style."
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPremiumPaywall) {
                PremiumPaywallView()
            }
        }
    }
}

// MARK: - Supporting Views

struct CurrentThemePreview: View {
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Theme preview circle
            ZStack {
                Circle()
                    .fill(theme.primaryGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: theme.accentColor.opacity(0.3), radius: 10)
                
                Text(theme.emoji)
                    .font(.system(size: 36))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(theme.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(theme.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if theme.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                        Text("Premium")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct ThemeSelectionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    var isPremium: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Theme preview
                ZStack {
                    Circle()
                        .fill(theme.primaryGradient)
                        .frame(width: 50, height: 50)
                    
                    if isPremium {
                        Circle()
                            .fill(.black.opacity(0.4))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                            .font(.caption)
                    } else {
                        Text(theme.emoji)
                            .font(.title3)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(theme.rawValue)
                            .font(.headline)
                            .foregroundColor(isPremium ? .secondary : .primary)
                        
                        if theme.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(theme.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? theme.accentColor : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Premium Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .orange.opacity(0.4), radius: 20)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                Text("Unlock Premium Themes")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Get access to 7 exclusive aesthetic themes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Features
                VStack(spacing: 16) {
                    FeatureRow(icon: "paintpalette.fill", text: "7 Premium Themes")
                    FeatureRow(icon: "sparkles", text: "Exclusive Color Palettes")
                    FeatureRow(icon: "star.fill", text: "Stand Out from the Crowd")
                    FeatureRow(icon: "heart.fill", text: "Support Development")
                }
                .padding(.vertical)
                
                Spacer()
                
                // Pricing
                VStack(spacing: 12) {
                    Button(action: {
                        // Unlock premium (for demo)
                        themeManager.unlockPremiumThemes()
                        dismiss()
                    }) {
                        Text("Unlock for $4.99")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    
                    Button("Maybe Later") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    ProfileCustomizationView()
}
