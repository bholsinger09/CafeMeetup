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
            .navigationTitle("Community Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brown)
                    }
                }
            }
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
                .foregroundColor(.gray)
            
            Text("No Posts Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Be the first to share a meetup or coffee chat!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Post") {
                showCreatePost = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.brown)
        }
        .padding()
    }
}

struct BlogPostCard: View {
    let post: BlogPost
    @EnvironmentObject var blogViewModel: BlogViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author info
            HStack {
                Circle()
                    .fill(Color.brown.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(post.authorName.prefix(1))
                            .font(.headline)
                            .foregroundColor(.brown)
                    )
                
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
                    .foregroundColor(.brown)
                }
                
                if let meetupDate = post.meetupDate {
                    HStack {
                        Image(systemName: "calendar")
                        Text(meetupDate, style: .date)
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
                                .background(Color.brown.opacity(0.1))
                                .foregroundColor(.brown)
                                .cornerRadius(12)
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
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        BlogFeedView()
            .environmentObject(BlogViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
