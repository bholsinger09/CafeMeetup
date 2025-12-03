import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName: String = ""
    @State private var college: String = ""
    @State private var state: String = ""
    @State private var city: String = ""
    @State private var favoriteCoffee: String = ""
    @State private var favoriteCoffeeShop: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $fullName)
                    TextField("College/University", text: $college)
                }
                
                Section("Location") {
                    TextField("State", text: $state)
                    TextField("City", text: $city)
                }
                
                Section("Coffee Preferences") {
                    TextField("Favorite Coffee", text: $favoriteCoffee)
                    TextField("Favorite Coffee Shop", text: $favoriteCoffeeShop)
                }
                
                Section("About Me") {
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("Tell others about yourself...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                        }
                        
                        TextEditor(text: $bio)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await authViewModel.updateProfile(
                                fullName: fullName,
                                college: college,
                                state: state,
                                city: city,
                                favoriteCoffee: favoriteCoffee,
                                favoriteCoffeeShop: favoriteCoffeeShop,
                                bio: bio.isEmpty ? nil : bio
                            )
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = authViewModel.currentUser else { return }
        fullName = user.fullName
        college = user.college
        state = user.state
        city = user.city
        favoriteCoffee = user.favoriteCoffee
        favoriteCoffeeShop = user.favoriteCoffeeShop
        bio = user.bio ?? ""
    }
    
    private var isValid: Bool {
        !fullName.isEmpty && !college.isEmpty && !state.isEmpty && !city.isEmpty && !favoriteCoffee.isEmpty && !favoriteCoffeeShop.isEmpty
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthenticationViewModel())
}
