import SwiftUI
import UIKit
import Photos

/// Utility for rendering SwiftUI views to images
public class ViewRenderer {
    public static let shared = ViewRenderer()
    
    /// Render a SwiftUI view to a UIImage
    public func renderImage<Content: View>(
        _ content: Content,
        size: CGSize = CGSize(width: 1080, height: 1920)
    ) -> UIImage? {
        let controller = UIHostingController(rootView: content)
        controller.view.frame = CGRect(origin: .zero, size: size)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    /// Render to square format
    public func renderToSquare<Content: View>(
        _ content: Content
    ) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        return renderImage(content, size: size)
    }
    
    /// Save image to photo library
    public func saveToPhotos(_ image: UIImage, completion: @escaping (Bool, String) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    completion(false, "Photo library access denied")
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(true, "Image saved successfully")
                    } else {
                        completion(false, error?.localizedDescription ?? "Failed to save")
                    }
                }
            }
        }
    }
}

/// View showing image save result notification
public struct ImageSaveResult: View {
    let success: Bool
    let onDismiss: () -> Void
    
    public init(success: Bool, onDismiss: @escaping () -> Void) {
        self.success = success
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(success ? .green : .red)
            
            Text(success ? "Saved Successfully!" : "Failed to Save")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .onTapGesture {
            onDismiss()
        }
    }
}

/// Result of saving an image (enum version for type safety)
public enum ImageSaveResultEnum: Hashable {
    case success
    case failure(String)
    
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}
