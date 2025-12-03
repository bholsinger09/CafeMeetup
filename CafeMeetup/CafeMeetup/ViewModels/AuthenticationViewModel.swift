import Foundation
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService.shared) {
        self.authService = authService
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                currentUser = try await authService.getCurrentUser()
                isAuthenticated = currentUser != nil
            } catch {
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    func signUp(email: String, password: String, fullName: String, college: String, state: String, city: String, address: String?, favoriteCoffee: String, favoriteCoffeeShop: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = User(
                email: email,
                fullName: fullName,
                college: college,
                state: state,
                city: city,
                address: address,
                favoriteCoffee: favoriteCoffee,
                favoriteCoffeeShop: favoriteCoffeeShop,
                lastActiveAt: Date()
            )
            
            currentUser = try await authService.signUp(email: email, password: password, user: user)
            isAuthenticated = true
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
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateProfile(fullName: String, college: String, state: String, city: String, address: String?, favoriteCoffee: String, favoriteCoffeeShop: String, bio: String?) async {
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
