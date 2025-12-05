import Foundation
import Combine

@MainActor
class DiscoveryViewModel: ObservableObject {
    @Published var potentialMatches: [User] = []
    @Published var currentUserIndex = 0
    @Published var showMatchPopup = false
    @Published var matchedUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var hasLoadedOnce = false
    
    private let matchService: MatchServiceProtocol
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var currentUser: User? {
        guard currentUserIndex < potentialMatches.count else { return nil }
        return potentialMatches[currentUserIndex]
    }
    
    init(matchService: MatchServiceProtocol = MatchService.shared, userService: UserServiceProtocol = UserService.shared) {
        self.matchService = matchService
        self.userService = userService
        
        // Listen for sign-out events
        NotificationCenter.default.publisher(for: .userDidSignOut)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.resetState()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadPotentialMatches(currentUserId: String, currentUserCity: String, currentUserState: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get users from same city/state
            var users = try await userService.fetchUsers(inCity: currentUserCity, state: currentUserState)
            
            // Filter out current user and already liked users
            users = users.filter { $0.id != currentUserId }
            
            // Shuffle for variety
            potentialMatches = users.shuffled()
            currentUserIndex = 0
            hasLoadedOnce = true
            
            print("[DiscoveryViewModel] Loaded \(potentialMatches.count) potential matches")
        } catch {
            errorMessage = error.localizedDescription
            print("[DiscoveryViewModel] Error loading matches: \(error)")
        }
        
        isLoading = false
    }
    
    func resetState() {
        potentialMatches = []
        currentUserIndex = 0
        showMatchPopup = false
        matchedUser = nil
        isLoading = false
        errorMessage = nil
        hasLoadedOnce = false
        print("[DiscoveryViewModel] State reset")
    }
    
    func likeUser(currentUserId: String, likedUser: User) async {
        do {
            let isMatch = try await matchService.addLike(userId: currentUserId, likedUserId: likedUser.id)
            
            if isMatch {
                matchedUser = likedUser
                showMatchPopup = true
                print("[DiscoveryViewModel] ✅ IT'S A MATCH with \(likedUser.fullName)!")
            }
            
            moveToNextUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func passUser() {
        moveToNextUser()
    }
    
    private func moveToNextUser() {
        currentUserIndex += 1
        if currentUserIndex >= potentialMatches.count {
            print("[DiscoveryViewModel] No more users to show")
        }
    }
    
    func resetDiscovery() {
        currentUserIndex = 0
        showMatchPopup = false
        matchedUser = nil
    }
}
