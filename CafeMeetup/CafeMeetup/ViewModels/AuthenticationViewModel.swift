import Foundation
import Combine
import CoreLocation

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthenticationServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService.shared, locationService: LocationServiceProtocol = LocationService.shared) {
        self.authService = authService
        self.locationService = locationService
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                currentUser = try await authService.getCurrentUser()
                isAuthenticated = currentUser != nil
                await updateLastActive()
            } catch {
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    func updateLastActive() async {
        guard var user = currentUser else { return }
        user.lastActiveAt = Date()
        currentUser = user
        // In a real app, this would persist to backend
    }
    
    private func getCurrentLocationForUser() async -> Location? {
        do {
            let coordinate = try await locationService.getCurrentLocation()
            print("[AuthViewModel] Got location for user: \(coordinate.latitude), \(coordinate.longitude)")
            return Location(coordinate: coordinate)
        } catch {
            print("[AuthViewModel] Failed to get location: \(error.localizedDescription)")
            return nil
        }
    }
    
    func signUp(email: String, password: String, fullName: String, college: String, state: String, city: String, address: String?, favoriteCoffee: String, favoriteCoffeeShop: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current location
            let location = await getCurrentLocationForUser()
            
            let user = User(
                email: email,
                fullName: fullName,
                college: college,
                state: state,
                city: city,
                address: address,
                favoriteCoffee: favoriteCoffee,
                favoriteCoffeeShop: favoriteCoffeeShop,
                location: location,
                lastActiveAt: Date()
            )
            
            currentUser = try await authService.signUp(email: email, password: password, user: user)
            isAuthenticated = true
            await updateLastActive()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await authService.signIn(email: email, password: password)
            isAuthenticated = true
            
            // Update location and lastActive on sign in
            if var user = currentUser {
                user.location = await getCurrentLocationForUser()
                user.lastActiveAt = Date()
                currentUser = user
                // In real app, persist to backend
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signInWithApple(userID: String, email: String, fullName: String?) async {
        print("🔐 [AuthViewModel] signInWithApple called")
        print("🔐 [AuthViewModel] userID: \(userID)")
        print("🔐 [AuthViewModel] email: \(email)")
        print("🔐 [AuthViewModel] fullName: \(fullName ?? "nil")")
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔐 [AuthViewModel] Calling authService.signInWithApple...")
            currentUser = try await authService.signInWithApple(userID: userID, email: email, fullName: fullName)
            isAuthenticated = true
            
            // Update location and lastActive for Apple sign in
            if var user = currentUser {
                user.location = await getCurrentLocationForUser()
                user.lastActiveAt = Date()
                currentUser = user
                print("✅ [AuthViewModel] Updated location for user")
            }
            
            print("✅ [AuthViewModel] Sign in successful")
            print("✅ [AuthViewModel] currentUser: \(currentUser?.email ?? "nil")")
        } catch {
            print("❌ [AuthViewModel] Sign in failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        print("🔐 [AuthViewModel] signInWithApple completed. isAuthenticated: \(isAuthenticated)")
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signOut()
            
            // Clear all state
            currentUser = nil
            isAuthenticated = false
            
            // Post notification to reset all view models
            NotificationCenter.default.post(name: .userDidSignOut, object: nil)
            
            print("🔐 [AuthViewModel] User signed out successfully")
        } catch {
            errorMessage = error.localizedDescription
            print("🔐 [AuthViewModel] Sign out error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func updateProfile(fullName: String, college: String, state: String, city: String, address: String?, favoriteCoffee: String, favoriteCoffeeShop: String, bio: String?, gender: String?, relationshipStatus: String?, profileImageURL: String? = nil) async {
        guard var user = currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            user.fullName = fullName
            user.college = college
            user.state = state
            user.city = city
            user.address = address
            user.favoriteCoffee = favoriteCoffee
            user.favoriteCoffeeShop = favoriteCoffeeShop
            user.bio = bio
            user.gender = gender
            user.relationshipStatus = relationshipStatus
            if let profileImageURL = profileImageURL {
                user.profileImageURL = profileImageURL
            }
            user.updatedAt = Date()
            user.lastActiveAt = Date()
            
            currentUser = try await authService.updateUser(user)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.deleteAccount()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
