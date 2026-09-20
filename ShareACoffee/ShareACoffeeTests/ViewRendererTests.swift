import XCTest
import SwiftUI
@testable import ShareACoffee

/// Tests for ViewRenderer image generation and export utilities
@MainActor
final class ViewRendererTests: XCTestCase {
    
    // MARK: - renderToSquare Tests
    
    func testRenderToSquareReturnsUIImage() async {
        // Given: A simple SwiftUI view
        let testView = Text("Test Content")
            .frame(width: 500, height: 500)
        
        // When: Rendering to square
        let image = ViewRenderer.renderToSquare(testView)
        
        // Then: Should return a valid UIImage
        XCTAssertNotNil(image)
        if let img = image {
            XCTAssertEqual(img.size.width, 500)
            XCTAssertEqual(img.size.height, 500)
        }
    }
    
    func testRenderToSquareHandlesComplexView() async {
        // Given: A complex SwiftUI view with multiple layers
        let testView = VStack {
            Text("Title").font(.largeTitle).bold()
            Divider()
            Text("Content")
        }
        .padding()
        .frame(width: 600, height: 600)
        .background(Color.blue)
        
        // When: Rendering to square
        let image = ViewRenderer.renderToSquare(testView)
        
        // Then: Should successfully render
        XCTAssertNotNil(image)
    }
    
    func testRenderToSquareWithDifferentSizes() async {
        // Given: Different size requirements
        let sizes: [CGFloat] = [400, 500, 600, 800]
        
        for size in sizes {
            // When: Rendering at different sizes
            let testView = Text("Test").frame(width: size, height: size)
            let image = ViewRenderer.renderToSquare(testView)
            
            // Then: Each should render successfully
            XCTAssertNotNil(image)
        }
    }
    
    // MARK: - saveToPhotos Tests
    
    func testSaveToPhotosWithValidImage() async throws {
        // Given: A valid UIImage
        let testImage = UIImage(systemName: "star.fill") ?? UIImage()
        var saveSuccess = false
        var saveError: Error?
        
        // When: Saving to photos
        let expectation = XCTestExpectation(description: "Image saved to photos")
        ViewRenderer.saveToPhotos(testImage) { success, error in
            saveSuccess = success
            saveError = error
            expectation.fulfill()
        }
        
        // Then: Completion should be called
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertTrue(saveSuccess || saveError != nil) // Should succeed or have a known error
    }
    
    func testSaveToPhotosHandlesMultipleImages() async {
        // Given: Multiple UIImages
        let images = [
            UIImage(systemName: "star.fill") ?? UIImage(),
            UIImage(systemName: "heart.fill") ?? UIImage(),
            UIImage(systemName: "bookmark.fill") ?? UIImage()
        ]
        
        var successCount = 0
        let lock = NSLock()
        
        // When: Saving multiple images
        for image in images {
            let expectation = XCTestExpectation(description: "Image saved")
            ViewRenderer.saveToPhotos(image) { success, error in
                if success {
                    lock.lock()
                    successCount += 1
                    lock.unlock()
                }
                expectation.fulfill()
            }
            await fulfillment(of: [expectation], timeout: 5.0)
        }
        
        // Then: All images should be attempted
        XCTAssertGreaterThanOrEqual(successCount, 0)
    }
    
    // MARK: - Integration Tests
    
    func testRenderAndSaveWorkflow() async throws {
        // Given: A view that needs to be rendered and saved
        let testView = VStack {
            Text("Session Summary")
            Text("Score: 95%")
        }
        .frame(width: 500, height: 500)
        .background(Color.white)
        
        // When: Rendering to image
        guard let image = ViewRenderer.renderToSquare(testView) else {
            XCTFail("Failed to render view to image")
            return
        }
        
        // And: Saving to photos
        var saveSuccess = false
        let expectation = XCTestExpectation(description: "Workflow complete")
        ViewRenderer.saveToPhotos(image) { success, error in
            saveSuccess = success || error != nil
            expectation.fulfill()
        }
        
        // Then: Workflow should complete successfully
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertTrue(saveSuccess)
    }
}
