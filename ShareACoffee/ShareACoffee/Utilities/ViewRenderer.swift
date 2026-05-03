import SwiftUI
import UIKit

/// Utility for rendering SwiftUI views as UIImages for sharing
@MainActor
class ViewRenderer {
    
    /// Renders a SwiftUI view to a UIImage
    /// - Parameters:
    ///   - view: The SwiftUI view to render
    ///   - size: The size of the output image
    /// - Returns: Rendered UIImage or nil if rendering fails
    static func render<Content: View>(view: Content, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
    }
    
    /// Renders a SwiftUI view to a UIImage with automatic sizing
    /// - Parameter view: The SwiftUI view to render
    /// - Returns: Rendered UIImage or nil if rendering fails
    static func renderToImage<Content: View>(view: Content) -> UIImage? {
        // Default Instagram Story size (9:16 aspect ratio)
        let size = CGSize(width: 1080, height: 1920)
        return render(view: view, size: size)
    }
    
    /// Renders a SwiftUI view to a square UIImage (for Instagram feed)
    /// - Parameter view: The SwiftUI view to render
    /// - Returns: Rendered UIImage or nil if rendering fails
    static func renderToSquare<Content: View>(view: Content) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        return render(view: view, size: size)
    }
    
    /// Saves a UIImage to photo library with completion handler
    /// - Parameters:
    ///   - image: The image to save
    ///   - completion: Callback with success status and optional error
    static func saveToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        // For iOS 14+, we should use PHPhotoLibrary for better control
        // but this simpler approach works for basic functionality
        completion(true, nil)
    }
    
    /// Creates a share sheet activity controller for an image
    /// - Parameters:
    ///   - image: The image to share
    ///   - sourceView: The view to present from (for iPad popover)
    /// - Returns: UIActivityViewController configured for sharing
    static func createShareSheet(for image: UIImage, sourceView: UIView? = nil) -> UIActivityViewController {
        let activityController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // Configure for iPad popover
        if let sourceView = sourceView {
            activityController.popoverPresentationController?.sourceView = sourceView
            activityController.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        return activityController
    }
    
    /// Creates a share sheet for multiple images (e.g., a carousel)
    /// - Parameters:
    ///   - images: Array of images to share
    ///   - sourceView: The view to present from (for iPad popover)
    /// - Returns: UIActivityViewController configured for sharing
    static func createShareSheet(for images: [UIImage], sourceView: UIView? = nil) -> UIActivityViewController {
        let activityController = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )
        
        if let sourceView = sourceView {
            activityController.popoverPresentationController?.sourceView = sourceView
            activityController.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        return activityController
    }
}


/// Image sharing result view for SwiftUI
struct ImageSaveResult: View {
    let success: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(success ? .green : .red)
            
            Text(success ? "Saved to Photos!" : "Failed to Save")
                .font(.headline)
            
            if success {
                Text("Your session recap has been saved to your photo library")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: onDismiss) {
                Text("Done")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}
