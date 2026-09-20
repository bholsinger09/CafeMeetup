import Foundation

/// Represents possible swipe actions on study buddy cards
public enum SwipeAction {
    case pass
    case like
    case superLike
    
    public var description: String {
        switch self {
        case .pass: return "Pass"
        case .like: return "Like"
        case .superLike: return "Super Like"
        }
    }
}
