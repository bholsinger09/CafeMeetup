import XCTest
@testable import ShareACoffeeAuth
import ShareACoffeeCore

final class ShareACoffeeAuthTests: XCTestCase {
    
    // MARK: - BlogPost Model Tests (imported from Blog package)
    func testAuthenticationViewModelInitialization() {
        let viewModel = AuthenticationViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    func testAuthenticationServiceExists() {
        let service = AuthenticationService.shared
        XCTAssertNotNil(service)
    }
}
