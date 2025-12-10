import SwiftUI

struct BlogFeedView: View {
    @EnvironmentObject var blogViewModel: BlogViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showCreatePost = false
    
    var body: some View {
        NavigationStack {
            Group {
                if blogViewModel.isLoading && blogViewModel.posts.isEmpty {
                    ProgressView("Loading posts...")
                } else if blogViewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(blogViewModel.posts) { post in
                                BlogPostCard(post: post)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await blogViewModel.fetchPosts()
                    }
                }
            }
            .navigationTitle("Academic Blog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.primaryGradient)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .task {
                if blogViewModel.posts.isEmpty {
                    await blogViewModel.fetchPosts()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundStyle(Color.primaryGradient)
            
            Text("No Posts Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.lightText)
            
            Text("Share study tips, organize group sessions, or post about academic topics!")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Create Post") {
                showCreatePost = true
            }
            .padding()
            .background(Color.accentGradient)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
        }
        .padding()
    }
}

struct BlogPostCard: View {
    let post: BlogPost
    @EnvironmentObject var blogViewModel: BlogViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var isLiked = false
    @State private var showDetail = false
    
    var body: some View {
        Button {
            showDetail = true
        } label: {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            BlogPostDetailView(post: post)
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author info
            HStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(post.authorName.prefix(1))
                            .font(.headline)
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
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Study course badge if this is a study meetup
                if post.isStudyMeetup, let course = post.studyCourse {
                    HStack {
                        Image(systemName: "book.fill")
                        Text(course)
                        if let topic = post.studyTopic {
                            Text("•")
                            Text(topic)
                                .lineLimit(1)
                        }
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.brown.opacity(0.2))
                    .foregroundColor(.brown)
                    .cornerRadius(8)
                }
                
                Text(post.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(post.content)
                    .font(.body)
                    .lineLimit(3)
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
                        
                        // Show max attendees for study meetups
                        if post.isStudyMeetup, let max = post.maxAttendees {
                            Text("•")
                            Image(systemName: "person.3.fill")
                            Text("Max \(max) students")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            
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
                }
            }
            
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
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "message")
                        .foregroundColor(.gray)
                    Text("\(post.commentCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Let's Meet indicator
                if post.meetupInterestCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.primaryPink)
                        Text("\(post.meetupInterestCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.darkSecondary)
        .cornerRadius(16)
        .shadow(color: Color.primaryPink.opacity(0.1), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        BlogFeedView()
            .environmentObject(BlogViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
