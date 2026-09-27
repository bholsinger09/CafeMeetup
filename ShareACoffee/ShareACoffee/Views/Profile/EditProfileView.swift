import SwiftUI
import ShareACoffeeCore
import ShareACoffeeAuth
import ShareACoffeeStudy
import ShareACoffeeCoffee
import ShareACoffeeSocial
import ShareACoffeeBlog
import ShareACoffeeDiscovery
import ShareACoffeeProfile

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
                        Text("United States").tag("United States")
                        Text("Canada").tag("Canada")
                        Text("United Kingdom").tag("United Kingdom")
                    }
                    
                    if country == "United States" || country == "Canada" {
                        Picker("State/Province", selection: $state) {
                            Text("Select State").tag("")
                            ForEach(getStatesForCountry(country), id: \.self) { stateName in
                                Text(stateName).tag(stateName)
                            }
                        }
                        
                        Picker("City", selection: $city) {
                            Text("Select City").tag("")
                            if !state.isEmpty {
                                ForEach(getCommonCities(for: country, state: state), id: \.self) { cityName in
                                    Text(cityName).tag(cityName)
                                }
                            }
                        }
                        .disabled(state.isEmpty)
                    } else {
                        Picker("City", selection: $city) {
                            Text("Select City").tag("")
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
        if country == "United States" || country == "Canada" {
            return basicFieldsValid && !state.isEmpty
        }
        
        // For countries without states, just check basic fields
        return basicFieldsValid
    }
    
    private func getStatesForCountry(_ country: String) -> [String] {
        switch country {
        case "Canada":
            return ["AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]
        case "United Kingdom":
            return ["England", "Scotland", "Wales", "Northern Ireland"]
        case "United States":
            return ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
        default:
            return []
        }
    }
    
    private func getCommonCities(for country: String, state: String) -> [String] {
        if country == "United States" {
            switch state {
            case "CA": return ["Los Angeles", "San Francisco", "San Diego", "San Jose", "Oakland"]
            case "NY": return ["New York", "Buffalo", "Rochester", "Albany", "Syracuse"]
            case "TX": return ["Houston", "Dallas", "Austin", "San Antonio", "Fort Worth"]
            case "FL": return ["Miami", "Tampa", "Orlando", "Jacksonville", "Fort Lauderdale"]
            default: return []
            }
        } else if country == "Canada" {
            switch state {
            case "ON": return ["Toronto", "Ottawa", "Hamilton", "London", "Markham"]
            case "QC": return ["Montreal", "Quebec City", "Laval", "Gatineau", "Longueuil"]
            case "BC": return ["Vancouver", "Victoria", "Surrey", "Burnaby", "Richmond"]
            case "AB": return ["Calgary", "Edmonton", "Red Deer", "Lethbridge", "St. Albert"]
            default: return []
            }
        }
        return []
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthenticationViewModel())
}
