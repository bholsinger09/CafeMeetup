import SwiftUI
import Photos

/// Utility class for rendering SwiftUI views to images and managing photo exports
@MainActor
public final class ViewRenderer {
    
    // MARK: - Static Methods
    
    /// Renders a SwiftUI view to a square UIImage
    /// - Parameter view: The SwiftUI view to render
    /// - Returns: A UIImage if rendering succeeds, nil otherwise
    public static func renderToSquare<V: View>(_ view: V) -> UIImage? {
        return renderView(view, size: CGSize(width: 500, height: 500))
    }
    
    /// Renders a SwiftUI view to a UIImage with custom size
    /// - Parameters:
    ///   - view: The SwiftUI view to render
    ///   - size: The target size for the rendered image
    /// - Returns: A UIImage if rendering succeeds, nil otherwise
    public static func renderView<V: View>(_ view: V, size: CGSize = CGSize(width: 500, height: 500)) -> UIImage? {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        
        // Set preferred size for SwiftUI layout
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // Render to image
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        }
        
        return image
    }
    
    /// Saves a UIImage to the photo library
    /// - Parameters:
    ///   - image: The UIImage to save
    ///   - completion: Closure called with success status and optional error
    public static func saveToPhotos(_ image: UIImage, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        // Request photo library access
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                let error = NSError(
                    domain: "ViewRenderer",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Photo library access not authorized"]
                )
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            // Save image to photo library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            })
        }
    }
    
    /// Generates a thumbnail image from a view
    /// - Parameters:
    ///   - view: The SwiftUI view to thumbnail
    ///   - size: The size of the thumbnail
    /// - Returns: A UIImage if rendering succeeds, nil otherwise
    public static func generateThumbnail<V: View>(_ view: V, size: CGSize) -> UIImage? {
        return renderView(view, size: size)
    }
}
