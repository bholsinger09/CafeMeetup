import SwiftUI
import Combine
import ShareACoffeeCore
import ShareACoffeeDiscovery

/// ViewModel for study buddy discovery
@MainActor
public class DiscoveryViewModel: ObservableObject {
    @Published public var recommendations: [StudyBuddyRecommendation] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    public init() {
        loadRecommendations()
    }
    
    public func loadRecommendations() {
        isLoading = true
        // Mock data - in production would load from service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
}
