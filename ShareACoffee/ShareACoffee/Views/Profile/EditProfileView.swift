import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName: String = ""
    @State private var college: String = ""
    @State private var state: String = ""
    @State private var city: String = ""
    @State private var country: String = "United States"
    @State private var address: String = ""
    @State private var favoriteCoffee: String = ""
    @State private var favoriteCoffeeShop: String = ""
    @State private var bio: String = ""
    @State private var gender: String = ""
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Photo") {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                            } else if let profileImageURL = authViewModel.currentUser?.profileImageURL,
                                      let uiImage = UIImage.fromBase64String(profileImageURL) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                            } else {
                                Circle()
                                    .fill(Color.primaryGradient)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(fullName.prefix(1).uppercased())
                                            .font(.system(size: 40, weight: .semibold))
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                            }
                            
                            Button {
                                showImagePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text(profileImage != nil || authViewModel.currentUser?.profileImageURL != nil ? "Change Photo" : "Add Photo")
                                }
                                .font(.subheadline)
                                .foregroundColor(.primaryPink)
                            }
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("Personal Information") {
                    TextField("Full Name", text: $fullName)
                    TextField("College/University", text: $college)
                }
                
                Section("Personal Details") {
                    Picker("Gender", selection: $gender) {
                        Text("Prefer not to say").tag("")
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                }
                
                Section("Location") {
                    Picker("Country", selection: $country) {
                        ForEach(LocationData.countries, id: \.self) { countryName in
                            Text(countryName).tag(countryName)
                        }
                    }
                    .onChange(of: country) { oldValue, newValue in
                        // Reset state and city when country changes
                        if oldValue != newValue {
                            state = ""
                            city = ""
                        }
                    }
                    
                    if LocationData.usesStates(country: country) {
                        Picker("State/Province", selection: $state) {
                            Text("Select \(country == "United Kingdom" ? "Region" : country == "Canada" ? "Province" : "State")").tag("")
                            ForEach(LocationData.statesOrProvinces(for: country), id: \.self) { stateName in
                                Text(stateName).tag(stateName)
                            }
                        }
                        .onChange(of: state) { oldValue, newValue in
                            // Reset city when state changes
                            if oldValue != newValue && !LocationData.cities(for: country, state: newValue).contains(city) {
                                city = ""
                            }
                        }
                        
                        Picker("City", selection: $city) {
                            Text("Select City").tag("")
                            ForEach(LocationData.cities(for: country, state: state), id: \.self) { cityName in
                                Text(cityName).tag(cityName)
                            }
                        }
                        .disabled(state.isEmpty)
                    } else {
                        Picker("City", selection: $city) {
                            Text("Select City").tag("")
                            ForEach(LocationData.cities(for: country, state: ""), id: \.self) { cityName in
                                Text(cityName).tag(cityName)
                            }
                        }
                    }
                    
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
                            saveAlertMessage = "Save button tapped. Starting..."
                            showSaveAlert = true
                            
                            print("🔍 [EditProfile] Save button tapped")
                            print("🔍 [EditProfile] Form valid: \(isValid)")
                            print("🔍 [EditProfile] Country: '\(country)'")
                            print("🔍 [EditProfile] State: '\(state)'")
                            print("🔍 [EditProfile] City: '\(city)'")
                            
                            let profileImageBase64 = profileImage?.toBase64String()
                            
                            print("🔍 [EditProfile] Calling updateProfile...")
                            await authViewModel.updateProfile(
                                fullName: fullName,
                                college: college,
                                state: state,
                                city: city,
                                country: country,
                                address: address.isEmpty ? nil : address,
                                favoriteCoffee: favoriteCoffee,
                                favoriteCoffeeShop: favoriteCoffeeShop,
                                bio: bio.isEmpty ? nil : bio,
                                gender: gender.isEmpty ? nil : gender,
                                profileImageURL: profileImageBase64
                            )
                            print("🔍 [EditProfile] updateProfile completed")
                            
                            if let error = authViewModel.errorMessage {
                                print("❌ [EditProfile] Error: \(error)")
                                saveAlertMessage = "Error: \(error)"
                            } else {
                                print("✅ [EditProfile] Profile updated successfully")
                                saveAlertMessage = "Profile saved successfully!"
                            }
                            
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .alert("Save Status", isPresented: $showSaveAlert) {
                Button("OK") { }
            } message: {
                Text(saveAlertMessage)
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = authViewModel.currentUser else { return }
        fullName = user.fullName
        college = user.college
        state = user.state
        city = user.city
        country = user.country
        address = user.address ?? ""
        favoriteCoffee = user.favoriteCoffee
        favoriteCoffeeShop = user.favoriteCoffeeShop
        bio = user.bio ?? ""
        gender = user.gender ?? ""
    }
    
    private var isValid: Bool {
        let basicFieldsValid = !fullName.isEmpty && !college.isEmpty && !city.isEmpty && !favoriteCoffee.isEmpty && !favoriteCoffeeShop.isEmpty
        
        // For countries with states, state must not be empty
        if LocationData.usesStates(country: country) {
            return basicFieldsValid && !state.isEmpty
        }
        
        // For countries without states, just check basic fields
        return basicFieldsValid
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthenticationViewModel())
}
