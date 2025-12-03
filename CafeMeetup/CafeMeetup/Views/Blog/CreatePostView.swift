import SwiftUI

struct CreatePostView: View {
    @EnvironmentObject var blogViewModel: BlogViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var coffeeShopName = ""
    @State private var selectedTags: Set<String> = []
    @State private var customTag = ""
    @State private var hasMeetupDate = false
    @State private var meetupDate = Date()
    
    private let suggestedTags = ["Meetup", "Coffee Chat", "Study Session", "Fellowship", "Bible Study", "Prayer", "Casual Hangout"]
    
    var body: some View {
        NavigationStack {
            Form {
                // Form sections here
                Section("Post Details") {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Share your thoughts, organize a meetup, or start a conversation...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                    }
                }
                
                Section("Coffee Shop (Optional)") {
                    TextField("Coffee Shop Name", text: $coffeeShopName)
                }
                
                Section("Meetup Date (Optional)") {
                    Toggle("Set Meetup Date", isOn: $hasMeetupDate)
                    
                    if hasMeetupDate {
                        DatePicker("Date", selection: $meetupDate, in: Date()...)
                    }
                }
                
                Section("Tags") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestedTags, id: \.self) { tag in
                                TagButton(
                                    tag: tag,
                                    isSelected: selectedTags.contains(tag)
                                ) {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    HStack {
                        TextField("Add custom tag", text: $customTag)
                        
                        Button("Add") {
                            if !customTag.isEmpty {
                                selectedTags.insert(customTag)
                                customTag = ""
                            }
                        }
                        .disabled(customTag.isEmpty)
                    }
                    
                    if !selectedTags.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(Array(selectedTags), id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text("#\(tag)")
                                        .font(.caption)
                                    
                                    Button {
                                        selectedTags.remove(tag)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.darkSecondary)
                                .foregroundColor(.primaryPink)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryPink.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundGradient)
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            guard let currentUser = authViewModel.currentUser else { return }
                            
                            await blogViewModel.createPost(
                                title: title,
                                content: content,
                                tags: Array(selectedTags),
                                coffeeShopId: nil,
                                coffeeShopName: coffeeShopName.isEmpty ? nil : coffeeShopName,
                                meetupDate: hasMeetupDate ? meetupDate : nil,
                                currentUser: currentUser
                            )
                            
                            dismiss()
                        }
                    } label: {
                        Text("Post")
                            .foregroundColor(isValid ? Color.primaryPink : .gray)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && !content.isEmpty
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("#\(tag)")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
        .background(isSelected ? AnyShapeStyle(Color.accentGradient) : AnyShapeStyle(Color.darkSecondary))
        .foregroundColor(isSelected ? .white : .secondaryText)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.clear : Color.primaryPink.opacity(0.2), lineWidth: 1)
        )
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    CreatePostView()
        .environmentObject(BlogViewModel())
        .environmentObject(AuthenticationViewModel())
}
