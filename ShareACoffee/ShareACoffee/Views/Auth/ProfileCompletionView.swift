import SwiftUI
import ShareACoffeeCore
import ShareACoffeeAuth
import ShareACoffeeStudy
import ShareACoffeeCoffee
import ShareACoffeeSocial
import ShareACoffeeBlog
import ShareACoffeeDiscovery
import ShareACoffeeProfile

struct ProfileCompletionView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    let onComplete: () -> Void
    
    @State private var fullName = ""
    @State private var college = ""
    @State private var country = "United States"
    @State private var state = ""
    @State private var city = ""
    @State private var address = ""
    @State private var favoriteCoffee = ""
    @State private var favoriteCoffeeShop = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(Color.primaryGradient)
                            
                            Text("Complete Your Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.lightText)
                            
                            Text("Help us find the best coffee meetups for you")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Personal Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Personal Information")
                                .font(.headline)
                                .foregroundColor(.lightText)
                            
                            TextField("Full Name", text: $fullName)
                                .textContentType(.name)
                                .padding()
                                .background(Color.darkSecondary)
                                .foregroundColor(.lightText)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                                )
                            
                            TextField("College/University", text: $college)
                                .padding()
                                .background(Color.darkSecondary)
                                .foregroundColor(.lightText)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Location
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Location")
                                .font(.headline)
                                .foregroundColor(.lightText)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Country")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("Select Country", selection: $country) {
                                    Text("United States").tag("United States")
                                    Text("Canada").tag("Canada")
                                    Text("United Kingdom").tag("United Kingdom")
                                }
                                .pickerStyle(.menu)
                                .padding(12)
                                .background(Color.darkSecondary)
                                .cornerRadius(8)
                                .onChange(of: country) { oldValue, newValue in
                                    if oldValue != newValue {
                                        state = ""
                                        city = ""
                                    }
                                }
                            }
                            
                            if country == "United States" || country == "Canada" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(country == "United Kingdom" ? "Region" : country == "Canada" ? "Province" : "State")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Picker("Select", selection: $state) {
                                        Text("Select").tag("")
                                        ForEach(getStatesForCountry(country), id: \.self) { stateName in
                                            Text(stateName).tag(stateName)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .padding(12)
                                    .background(Color.darkSecondary)
                                    .cornerRadius(8)
                                    .onChange(of: state) { oldValue, newValue in
                                        if oldValue != newValue {
                                            city = ""
                                        }
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("City")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("Select City", selection: $city) {
                                    Text("Select City").tag("")
                                    ForEach(getCommonCities(for: country, state: state), id: \.self) { cityName in
                                        Text(cityName).tag(cityName)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(12)
                                .background(Color.darkSecondary)
                                .cornerRadius(8)
                                .disabled((country == "United States" || country == "Canada") && state.isEmpty)
                            }
                            
                            if (country == "United States" || country == "Canada") && state.isEmpty {
                                Text("Please select a \(country == "United Kingdom" ? "region" : country == "Canada" ? "province" : "state") first")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("Address (Optional)", text: $address)
                                .padding()
                                .background(Color.darkSecondary)
                                .foregroundColor(.lightText)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Coffee Preferences
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Coffee Preferences")
                                .font(.headline)
                                .foregroundColor(.lightText)
                            
                            TextField("Favorite Coffee", text: $favoriteCoffee)
                                .padding()
                                .background(Color.darkSecondary)
                                .foregroundColor(.lightText)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                                )
                            
                            Text("e.g., Vanilla Latte, Cappuccino, Cold Brew")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("Favorite Coffee Shop", text: $favoriteCoffeeShop)
                                .padding()
                                .background(Color.darkSecondary)
                                .foregroundColor(.lightText)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryPink.opacity(0.2), lineWidth: 1)
                                )
                            
                            Text("e.g., Starbucks, Local Cafe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Complete Button
                        Button {
                            completeProfile()
                        } label: {
                            Text("Complete Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.primaryGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(12)
                                .shadow(color: Color.primaryPink.opacity(0.3), radius: 8)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Complete Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Pre-fill with existing user data if available
                if let user = authViewModel.currentUser {
                    fullName = user.fullName
                    college = user.college
                    country = user.country
                    state = user.state
                    city = user.city
                    address = user.address ?? ""
                    favoriteCoffee = user.favoriteCoffee
                    favoriteCoffeeShop = user.favoriteCoffeeShop
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !college.isEmpty &&
        !state.isEmpty &&
        !city.isEmpty &&
        !favoriteCoffee.isEmpty &&
        !favoriteCoffeeShop.isEmpty
    }
    
    private func completeProfile() {
        guard var user = authViewModel.currentUser else {
            errorMessage = "No user found"
            showError = true
            return
        }
        
        print("💾 [ProfileCompletion] Updating user profile")
        print("💾 [ProfileCompletion] Before - college: '\(user.college)', state: '\(user.state)', city: '\(user.city)'")
        
        // Update user with completed information
        user.fullName = fullName
        user.college = college
        user.country = country
        user.state = state
        user.city = city
        user.address = address.isEmpty ? nil : address
        user.favoriteCoffee = favoriteCoffee
        user.favoriteCoffeeShop = favoriteCoffeeShop
        user.updatedAt = Date()
        
        print("💾 [ProfileCompletion] After - college: '\(user.college)', state: '\(user.state)', city: '\(user.city)'")
        
        Task {
            do {
                authViewModel.currentUser = try await authViewModel.updateUser(user)
                print("✅ [ProfileCompletion] Profile updated successfully")
                
                // Call completion handler and dismiss
                onComplete()
            } catch {
                print("❌ [ProfileCompletion] Failed to update profile: \(error)")
                errorMessage = "Failed to update profile: \(error.localizedDescription)"
                showError = true
            }
        }
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
    ProfileCompletionView(onComplete: {})
        .environmentObject(AuthenticationViewModel())
}
