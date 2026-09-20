import XCTest
@testable import ShareACoffeeAuth
@testable import ShareACoffeeCore

/// Tests to validate Auth package imports and type accessibility
class AuthPackageValidationTests: XCTestCase {
    
    // MARK: - Service Import Tests
    
    func testAuthenticationServiceHasUserTypeAccess() {
        // This test verifies that AuthenticationService can access User type
        // If this compiles without errors, the import is correct
        
        let service = AuthenticationService()
        XCTAssertNotNil(service)
    }
    
    func testUserServiceHasUserTypeAccess() {
        // This test verifies that UserService can access User type
        let service = UserService()
        XCTAssertNotNil(service)
    }
    
    func testAuthenticationViewModelHasUserTypeAccess() {
        // This test verifies that AuthenticationViewModel can access User type
        let viewModel = AuthenticationViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testAuthenticationServiceConformsToProtocol() {
        let service = AuthenticationService()
        
        // If this compiles, the protocol conformance is correct
        let _: AuthenticationServiceProtocol = service
        XCTAssertNotNil(service)
    }
    
    func testUserServiceConformsToProtocol() {
        let service = UserService()
        
        // If this compiles, the protocol conformance is correct
        let _: UserServiceProtocol = service
        XCTAssertNotNil(service)
    }
    
    // MARK: - Type Scope Tests
    
    func testCanCreateUserInAuthPackage() {
        // This test ensures User type is properly accessible from Core
        let user = User(
            id: "auth-test-123",
            firstName: "Auth",
            lastName: "Test",
            email: "auth@test.com",
            profileImageURL: nil,
            bio: "Testing auth package imports",
            academicLevel: .undergraduate,
            favoriteSubjects: ["Computer Science"],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 4.0,
            createdAt: Date()
        )
        
        XCTAssertEqual(user.firstName, "Auth")
        XCTAssertEqual(user.lastName, "Test")
    }
    
    func testCanUseUserLocationInAuthPackage() {
        // This test ensures User.Location is accessible from Core
        let location = User.Location(latitude: 40.7128, longitude: -74.0060)
        
        XCTAssertEqual(location.latitude, 40.7128)
        XCTAssertEqual(location.longitude, -74.0060)
    }
    
    // MARK: - Cross-Package Dependency Tests
    
    func testAuthPackageDependsOnCore() {
        // Create a User (from Core) and verify it's accessible in Auth package
        let user = User(
            id: "core-user-123",
            firstName: "Core",
            lastName: "User",
            email: "core@test.com",
            profileImageURL: nil,
            bio: nil,
            academicLevel: .undergraduate,
            favoriteSubjects: [],
            preferences: [:],
            location: User.Location(latitude: 0.0, longitude: 0.0),
            rating: 5.0,
            createdAt: Date()
        )
        
        // Verify all properties are accessible
        XCTAssertNotNil(user.id)
        XCTAssertNotNil(user.firstName)
        XCTAssertNotNil(user.location)
    }
}
