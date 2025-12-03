import SwiftUI

struct ChatView: View {
    let otherUser: User
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var messageViewModel = MessageViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var messageText = ""
    @State private var showGiftPicker = false
    @State private var showIcebreakerPicker = false
    @State private var isPriorityMessage = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messageViewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.senderId == authViewModel.currentUser?.id,
                                    otherUserName: otherUser.fullName
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messageViewModel.messages.count) { _, _ in
                        if let lastMessage = messageViewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input Area
                VStack(spacing: 0) {
                    // Icebreaker/Gift/Priority buttons
                    HStack(spacing: 16) {
                        Button {
                            showIcebreakerPicker.toggle()
                        } label: {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                        }
                        
                        Button {
                            showGiftPicker.toggle()
                        } label: {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.primaryPink)
                        }
                        
                        Button {
                            isPriorityMessage.toggle()
                        } label: {
                            Image(systemName: isPriorityMessage ? "star.fill" : "star")
                                .foregroundColor(isPriorityMessage ? .yellow : .gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Message input
                    HStack(spacing: 12) {
                        TextField("Message...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(messageText.isEmpty ? .gray : .primaryPink)
                                .font(.title3)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding()
                }
                .background(Color.darkSecondary)
            }
            .background(Color.backgroundGradient)
            .navigationTitle(otherUser.fullName)
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadMessages()
            }
            .sheet(isPresented: $showGiftPicker) {
                GiftPickerView { giftType in
                    sendGift(giftType)
                    showGiftPicker = false
                }
            }
            .sheet(isPresented: $showIcebreakerPicker) {
                IcebreakerPickerView { question in
                    messageText = question
                    showIcebreakerPicker = false
                }
            }
        }
    }
    
    private func loadMessages() async {
        guard let currentUserId = authViewModel.currentUser?.id else { return }
        await messageViewModel.loadConversation(userId1: currentUserId, userId2: otherUser.id)
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty, let currentUserId = authViewModel.currentUser?.id else { return }
        
        Task {
            await messageViewModel.sendMessage(
                senderId: currentUserId,
                receiverId: otherUser.id,
                content: messageText,
                isPriority: isPriorityMessage
            )
            messageText = ""
            isPriorityMessage = false
        }
    }
    
    private func sendGift(_ giftType: GiftType) {
        guard let currentUserId = authViewModel.currentUser?.id else { return }
        
        Task {
            await messageViewModel.sendGift(
                senderId: currentUserId,
                receiverId: otherUser.id,
                giftType: giftType
            )
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    let otherUserName: String
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Priority badge
                if message.isPriority {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("Priority")
                            .font(.caption2)
                    }
                    .foregroundColor(.yellow)
                }
                
                // Gift display
                if let giftType = message.giftType {
                    HStack(spacing: 8) {
                        Text(giftType.emoji)
                            .font(.system(size: 40))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(giftType.displayName)
                                .font(.headline)
                            Text(message.content)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.primaryPink.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                } else {
                    // Regular message
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            isFromCurrentUser ?
                                AnyShapeStyle(Color.accentGradient) :
                                AnyShapeStyle(Color.darkSecondary)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                
                // Time and read receipt
                HStack(spacing: 4) {
                    Text(message.sentAt, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if isFromCurrentUser {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(message.isRead ? .green : .secondary)
                    }
                }
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

struct GiftPickerView: View {
    let onGiftSelected: (GiftType) -> Void
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(GiftType.allCases, id: \.self) { giftType in
                        Button {
                            onGiftSelected(giftType)
                        } label: {
                            VStack(spacing: 12) {
                                Text(giftType.emoji)
                                    .font(.system(size: 60))
                                
                                Text(giftType.displayName)
                                    .font(.headline)
                                    .foregroundColor(.lightText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color.darkSecondary)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color.backgroundGradient)
            .navigationTitle("Send a Gift")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct IcebreakerPickerView: View {
    let onQuestionSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(IcebreakerQuestion.questions, id: \.self) { question in
                    Button {
                        onQuestionSelected(question)
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            
                            Text(question)
                                .foregroundColor(.lightText)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundGradient)
            .navigationTitle("Icebreaker Questions")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChatView(otherUser: User(
        email: "test@example.com",
        fullName: "Jane Doe",
        college: "Boise State",
        state: "Idaho",
        city: "Boise",
        favoriteCoffee: "Latte",
        favoriteCoffeeShop: "Starbucks"
    ))
    .environmentObject(AuthenticationViewModel())
}
