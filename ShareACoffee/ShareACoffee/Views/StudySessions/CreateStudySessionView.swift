import SwiftUI

struct CreateStudySessionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var sessionService: StudySessionService
    
    @State private var courseCode = ""
    @State private var courseName = ""
    @State private var studyTopic = ""
    @State private var selectedCafe = ""
    @State private var selectedDate = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var duration = 120 // minutes
    @State private var maxAttendees = 6
    @State private var isPublic = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showNearbyCoffeeShops = false
    
    private let durationOptions = [60, 90, 120, 150, 180]
    private let attendeeOptions = [3, 4, 5, 6, 7, 8]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Information")) {
                    TextField("Course Code (e.g., CS 101)", text: $courseCode)
                        .autocapitalization(.allCharacters)
                    
                    TextField("Course Name", text: $courseName)
                    
                    TextField("Study Topic (e.g., Chapter 5 Review)", text: $studyTopic)
                }
                
                Section(header: Text("Location & Time")) {
                    // Coffee Shop Selection
                    Button(action: {
                        showNearbyCoffeeShops = true
                    }) {
                        HStack {
                            Text("Coffee Shop")
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedCafe.isEmpty {
                                Text("Select a café")
                                    .foregroundColor(.secondary)
                            } else {
                                Text(selectedCafe)
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $selectedDate, in: Date()...)
                        .datePickerStyle(.compact)
                    
                    Picker("Duration", selection: $duration) {
                        ForEach(durationOptions, id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                }
                
                Section(header: Text("Group Settings")) {
                    Picker("Max Attendees", selection: $maxAttendees) {
                        ForEach(attendeeOptions, id: \.self) { count in
                            Text("\(count) people").tag(count)
                        }
                    }
                    
                    Toggle("Public Session", isOn: $isPublic)
                    
                    Text("Public sessions are visible to all students in this course")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Study sessions require at least 3 people to emphasize group collaboration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Create Study Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createSession()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showNearbyCoffeeShops) {
                NearbyCoffeeShopsView(selectedCafeName: $selectedCafe)
            }
        }
    }
    
    private var isFormValid: Bool {
        !courseCode.isEmpty &&
        !courseName.isEmpty &&
        !studyTopic.isEmpty &&
        !selectedCafe.isEmpty
    }
    
    private func createSession() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        sessionService.createStudySession(
            courseCode: courseCode,
            courseName: courseName,
            topic: studyTopic,
            cafeId: UUID().uuidString,
            cafeName: selectedCafe,
            date: selectedDate,
            duration: duration,
            maxAttendees: maxAttendees,
            isPublic: isPublic
        )
        
        dismiss()
    }
}

#Preview {
    CreateStudySessionView(sessionService: StudySessionService(userId: "preview"))
}
