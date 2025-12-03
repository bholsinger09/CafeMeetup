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
    
    func signUp(email: String, password: String, fullName: String, college: String, state: String, city: String, favoriteCoffee: String, favoriteCoffeeShop: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = User(
                email: email,
                fullName: fullName,
                college: college,
                state: state,
                city: city,
                favoriteCoffee: favoriteCoffee,
                favoriteCoffeeShop: favoriteCoffeeShop
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
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await authService.signInWithApple(userID: userID, email: email, fullName: fullName)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
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
    
    func updateProfile(fullName: String, college: String, state: String, city: String, favoriteCoffee: String, favoriteCoffeeShop: String, bio: String?) async {
        guard var user = currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            user.fullName = fullName
            user.college = college
            user.state = state
            user.city = city
            user.favoriteCoffee = favoriteCoffee
            user.favoriteCoffeeShop = favoriteCoffeeShop
            user.bio = bio
            user.updatedAt = Date()
            
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
