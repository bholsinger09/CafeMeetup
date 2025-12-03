import SwiftUI

struct BlogPostDetailView: View {
    let post: BlogPost
    @EnvironmentObject var blogViewModel: BlogViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isLiked = false
    @State private var hasInterest = false
    @State private var meetupInterests: [MeetupInterest] = []
    @State private var showInterestsList = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Author info
                    HStack {
                        Circle()
                            .fill(Color.primaryGradient)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(post.authorName.prefix(1))
                                    .font(.title3)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.authorName)
                                .font(.headline)
                            
                            Text(post.createdAt, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(post.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(post.content)
                            .font(.body)
                        
                        if let coffeeShopName = post.coffeeShopName {
                            HStack {
                                Image(systemName: "location.fill")
                                Text(coffeeShopName)
                            }
                            .font(.subheadline)
                            .foregroundColor(.primaryPink)
                        }
                        
                        if let meetupDate = post.meetupDate {
                            HStack {
                                Image(systemName: "calendar")
                                Text(meetupDate, style: .date)
                                Text(meetupDate, style: .time)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tags
                    if !post.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(post.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
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
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Actions
                    HStack(spacing: 24) {
                        Button {
                            Task {
                                if isLiked {
                                    await blogViewModel.unlikePost(postId: post.id, userId: authViewModel.currentUser?.id ?? "")
                                } else {
                                    await blogViewModel.likePost(postId: post.id, userId: authViewModel.currentUser?.id ?? "")
                                }
                                isLiked.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(isLiked ? .red : .gray)
                                Text("\(post.likeCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "message")
                                .foregroundColor(.gray)
                            Text("\(comments.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Let's Meet Button
                        Button {
                            Task {
                                if hasInterest {
                                    await blogViewModel.removeMeetupInterest(postId: post.id, userId: authViewModel.currentUser?.id ?? "")
                                } else {
                                    if let currentUser = authViewModel.currentUser {
                                        await blogViewModel.addMeetupInterest(postId: post.id, currentUser: currentUser)
                                    }
                                }
                                hasInterest.toggle()
                                await loadMeetupInterests()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: hasInterest ? "cup.and.saucer.fill" : "cup.and.saucer")
                                Text("Let's Meet")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(hasInterest ? AnyShapeStyle(Color.accentGradient) : AnyShapeStyle(Color.darkSecondary))
                            .foregroundColor(hasInterest ? .white : .primaryPink)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.primaryPink.opacity(0.3), lineWidth: hasInterest ? 0 : 1)
                            )
                        }
                        
                        if post.meetupInterestCount > 0 {
                            Button {
                                showInterestsList = true
                            } label: {
                                Text("\(post.meetupInterestCount)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Comments Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Comments")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Comment Input
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.primaryGradient)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(authViewModel.currentUser?.fullName.prefix(1) ?? "?")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                            
                            TextField("Add a comment...", text: $newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button {
                                Task {
                                    await submitComment()
                                }
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(newCommentText.isEmpty ? .gray : .primaryPink)
                            }
                            .disabled(newCommentText.isEmpty)
                        }
                        .padding(.horizontal)
                        
                        // Comments List
                        if comments.isEmpty {
                            Text("No comments yet. Be the first!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color.backgroundGradient)
            .navigationTitle("Post")
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
                await loadComments()
                await loadMeetupInterests()
            }
            .sheet(isPresented: $showInterestsList) {
                MeetupInterestsListView(interests: meetupInterests)
            }
        }
    }
    
    private func submitComment() async {
        guard !newCommentText.isEmpty, let currentUser = authViewModel.currentUser else { return }
        
        await blogViewModel.addComment(postId: post.id, content: newCommentText, currentUser: currentUser)
        newCommentText = ""
        await loadComments()
    }
    
    private func loadComments() async {
        comments = await blogViewModel.fetchComments(postId: post.id)
    }
    
    private func loadMeetupInterests() async {
        meetupInterests = await blogViewModel.fetchMeetupInterests(postId: post.id)
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.primaryGradient)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(comment.authorName.prefix(1))
                        .font(.caption)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(comment.content)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct MeetupInterestsListView: View {
    let interests: [MeetupInterest]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(interests) { interest in
                VStack(alignment: .leading, spacing: 4) {
                    Text(interest.userName)
                        .font(.headline)
                    
                    Text(interest.userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(interest.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Interested People")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BlogPostDetailView(post: BlogPost(
        authorId: "1",
        authorName: "John Doe",
        title: "Coffee Meetup",
        content: "Anyone want to grab coffee this weekend?",
        tags: ["Meetup", "Coffee Chat"]
    ))
    .environmentObject(BlogViewModel())
    .environmentObject(AuthenticationViewModel())
}
