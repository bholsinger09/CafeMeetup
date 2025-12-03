import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName: String = ""
    @State private var college: String = ""
    @State private var state: String = ""
    @State private var city: String = ""
    @State private var address: String = ""
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
                    Picker("State", selection: $state) {
                        Text("Select State").tag("")
                        ForEach(LocationData.states, id: \.self) { stateName in
                            Text(stateName).tag(stateName)
                        }
                    }
                    .onChange(of: state) { oldValue, newValue in
                        // Reset city when state changes
                        if oldValue != newValue && !LocationData.cities(for: newValue).contains(city) {
                            city = ""
                        }
                    }
                    
                    Picker("City", selection: $city) {
                        Text("Select City").tag("")
                        ForEach(LocationData.cities(for: state), id: \.self) { cityName in
                            Text(cityName).tag(cityName)
                        }
                    }
                    .disabled(state.isEmpty)
                    
                    TextField("Address (Optional)", text: $address)
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
            .scrollContentBackground(.hidden)
            .background(Color.backgroundGradient)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await authViewModel.updateProfile(
                                fullName: fullName,
                                college: college,
                                state: state,
                                city: city,
                                address: address.isEmpty ? nil : address,
                                favoriteCoffee: favoriteCoffee,
                                favoriteCoffeeShop: favoriteCoffeeShop,
                                bio: bio.isEmpty ? nil : bio
                            )
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                            .foregroundColor(isValid ? Color.primaryPink : .gray)
                            .fontWeight(.semibold)
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
        address = user.address ?? ""
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
