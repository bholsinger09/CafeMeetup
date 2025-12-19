import Foundation
import Combine

@MainActor
class MatchViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let matchService: MatchServiceProtocol
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    convenience init() {
        self.init(matchService: MatchService.shared, userService: UserService.shared)
    }
    
    init(matchService: MatchServiceProtocol, userService: UserServiceProtocol) {
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
    
    func fetchMatches(forUserId userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            matches = try await matchService.getMatches(forUserId: userId)
            print("[MatchViewModel] Loaded \(matches.count) matches")
        } catch {
            errorMessage = error.localizedDescription
            print("[MatchViewModel] Error fetching matches: \(error)")
        }
        
        isLoading = false
    }
    
    func resetState() {
        matches = []
        isLoading = false
        errorMessage = nil
        print("[MatchViewModel] State reset")
    }
    
    func unmatch(matchId: String) async {
        do {
            try await matchService.unmatch(matchId: matchId)
            matches.removeAll(where: { $0.id == matchId })
            print("[MatchViewModel] Unmatched \(matchId)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func getMatchedUser(match: Match, currentUserId: String) async -> User? {
        let otherUserId = match.otherUserId(currentUserId: currentUserId)
        do {
            return try await userService.fetchUser(id: otherUserId)
        } catch {
            print("[MatchViewModel] Error fetching user \(otherUserId): \(error)")
            return nil
        }
    }
}
