import SwiftUI

struct AvatarPickerView: View {
    @Binding var selectedAvatarId: String?
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: Avatar.AvatarCategory = .marvel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(Avatar.AvatarCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Avatar Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(AvatarSystem.avatars(in: selectedCategory)) { avatar in
                            AvatarCard(
                                avatar: avatar,
                                isSelected: selectedAvatarId == avatar.id
                            ) {
                                selectedAvatarId = avatar.id
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Choose Your Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct AvatarCard: View {
    let avatar: Avatar
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? 
                              LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 70, height: 70)
                    
                    Text(avatar.emoji)
                        .font(.system(size: 35))
                    
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                    }
                }
                
                Text(avatar.name)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(height: 30)
            }
        }
        .buttonStyle(.plain)
    }
}

// Preview Avatar Display Component
struct AvatarDisplayView: View {
    let avatar: Avatar
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Text(avatar.emoji)
                .font(.system(size: size * 0.5))
            
            Circle()
                .stroke(Color.white, lineWidth: size * 0.04)
                .frame(width: size, height: size)
        }
        .shadow(color: .black.opacity(0.2), radius: size * 0.1)
    }
    
    private var gradientColors: [Color] {
        switch avatar.category {
        case .marvel:
            return [.red, .yellow]
        case .dc:
            return [.blue, .cyan]
        case .cartoon:
            return [.orange, .pink]
        case .anime:
            return [.purple, .pink]
        case .classic:
            return [.yellow, .orange]
        }
    }
}

#Preview {
    AvatarPickerView(selectedAvatarId: .constant("wednesday"))
}
