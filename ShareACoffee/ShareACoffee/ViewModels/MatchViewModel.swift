import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeSocial

/// ViewModel for user matching and connections
@MainActor
public class MatchViewModel: ObservableObject {
    @Published public var matches: [Match] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    public init() {
        loadMatches()
    }
    
    public func loadMatches() {
        isLoading = true
        // Mock data - in production would load from service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
}
