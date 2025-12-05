import SwiftUI

/// Study Sessions View - Unique to LatteLink: Find study partners and academic dates
struct StudySessionsView: View {
    @StateObject private var experienceService = CoffeeExperienceService.shared
    @State private var showCreateSession = false
    @State private var selectedSubject: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Study & Connect")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Find study partners and turn study sessions into coffee dates")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Create Session Button
                    Button(action: { showCreateSession = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Study Session")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Subject Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(StudySubject.allCases, id: \.self) { subject in
                                SubjectChip(
                                    subject: subject,
                                    isSelected: selectedSubject == subject.rawValue,
                                    action: {
                                        selectedSubject = selectedSubject == subject.rawValue ? nil : subject.rawValue
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upcoming Sessions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Sessions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        let sessions = experienceService.getPublicSessions(subject: selectedSubject)
                        
                        if sessions.isEmpty {
                            EmptyStateView(
                                icon: "book.circle",
                                title: "No Sessions Yet",
                                message: "Be the first to create a study session!"
                            )
                            .padding()
                        } else {
                            ForEach(sessions) { session in
                                StudySessionCard(session: session)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreateSession) {
                CreateStudySessionView()
            }
        }
    }
}

struct SubjectChip: View {
    let subject: StudySubject
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(subject.emoji)
                Text(subject.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct StudySessionCard: View {
    let session: StudySession
    @State private var showJoinSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.subject)
                        .font(.headline)
                    if let courseNumber = session.courseNumber {
                        Text(courseNumber)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(session.attendeeIds.count)/\(session.maxAttendees)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            // Topic
            Text(session.studyTopic)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Divider()
            
            // Details
            HStack(spacing: 16) {
                Label(session.cafeName, systemImage: "cup.and.saucer.fill")
                    .font(.caption)
                
                Label(session.scheduledDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                
                Label("\(session.duration) min", systemImage: "clock")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // Join Button
            if !session.isFull {
                Button(action: { showJoinSheet = true }) {
                    Text("Join Session")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Text("Session Full")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
}

struct CreateStudySessionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var experienceService = CoffeeExperienceService.shared
    @State private var subject = "Computer Science"
    @State private var courseNumber = ""
    @State private var studyTopic = ""
    @State private var selectedCafe = "The Human Bean"
    @State private var selectedDate = Date().addingTimeInterval(86400)
    @State private var duration = 120
    @State private var maxAttendees = 4
    @State private var isPublic = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Subject") {
                    Picker("Subject", selection: $subject) {
                        ForEach(StudySubject.allCases, id: \.self) { subject in
                            Text("\(subject.emoji) \(subject.rawValue)").tag(subject.rawValue)
                        }
                    }
                    
                    TextField("Course Number (optional)", text: $courseNumber)
                }
                
                Section("Details") {
                    TextField("What are you studying?", text: $studyTopic)
                    
                    DatePicker("Date & Time", selection: $selectedDate, in: Date()...)
                    
                    Picker("Duration", selection: $duration) {
                        Text("1 hour").tag(60)
                        Text("2 hours").tag(120)
                        Text("3 hours").tag(180)
                    }
                }
                
                Section("Location") {
                    TextField("Coffee Shop", text: $selectedCafe)
                }
                
                Section("Group Size") {
                    Stepper("Max \(maxAttendees) people", value: $maxAttendees, in: 2...10)
                    
                    Toggle("Public Session", isOn: $isPublic)
                    Text("Public sessions are visible to all your matches")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Create Study Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createSession()
                    }
                    .disabled(studyTopic.isEmpty)
                }
            }
        }
    }
    
    private func createSession() {
        Task {
            try? await experienceService.createStudySession(
                hostId: "current_user",
                hostName: "You",
                subject: subject,
                courseNumber: courseNumber.isEmpty ? nil : courseNumber,
                studyTopic: studyTopic,
                cafeId: "cafe1",
                cafeName: selectedCafe,
                scheduledDate: selectedDate,
                duration: duration,
                maxAttendees: maxAttendees,
                isPublic: isPublic
            )
            dismiss()
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    StudySessionsView()
}
