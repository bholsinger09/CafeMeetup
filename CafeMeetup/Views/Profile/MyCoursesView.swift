import SwiftUI

/// My Classes View - Display and manage current courses
/// Emphasizes academic profile over dating profile
struct MyCoursesView: View {
    @State private var courses: [Course] = []
    @State private var showAddCourse = false
    
    var body: some View {
        NavigationView {
            VStack {
                if courses.isEmpty {
                    emptyState
                } else {
                    coursesList
                }
            }
            .navigationTitle("My Classes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCourse = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $showAddCourse) {
                AddCourseView(courses: $courses)
            }
            .onAppear {
                loadMockCourses()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Classes Added")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your current courses to find study partners and join study sessions")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showAddCourse = true }) {
                Text("Add Your First Class")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(12)
            }
        }
    }
    
    private var coursesList: some View {
        List {
            ForEach(courses) { course in
                CourseRow(course: course)
            }
            .onDelete(perform: deleteCourse)
        }
    }
    
    private func deleteCourse(at offsets: IndexSet) {
        courses.remove(atOffsets: offsets)
    }
    
    private func loadMockCourses() {
        courses = [
            Course(
                courseCode: "CS 101",
                courseName: "Introduction to Programming",
                department: "Computer Science",
                professor: "Dr. Sarah Johnson",
                semester: "Spring 2026",
                meetingDays: ["Monday", "Wednesday", "Friday"],
                meetingTime: "10:00 AM - 11:20 AM",
                credits: 4
            ),
            Course(
                courseCode: "MATH 250",
                courseName: "Calculus II",
                department: "Mathematics",
                professor: "Prof. Michael Chen",
                semester: "Spring 2026",
                meetingDays: ["Tuesday", "Thursday"],
                meetingTime: "2:00 PM - 3:50 PM",
                credits: 4
            ),
            Course(
                courseCode: "ENGL 102",
                courseName: "English Composition",
                department: "English",
                professor: "Dr. Emily Taylor",
                semester: "Spring 2026",
                meetingDays: ["Monday", "Wednesday"],
                meetingTime: "1:00 PM - 2:20 PM",
                credits: 3
            )
        ]
    }
}

struct CourseRow: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(course.courseCode)
                    .font(.headline)
                    .foregroundColor(.brown)
                
                Spacer()
                
                Text("\(course.credits) credits")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.brown.opacity(0.2))
                    .cornerRadius(6)
            }
            
            Text(course.courseName)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            if let professor = course.professor {
                Text(professor)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let schedule = course.scheduleDisplay {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(schedule)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Text(course.semester)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AddCourseView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var courses: [Course]
    
    @State private var courseCode = ""
    @State private var courseName = ""
    @State private var department = "Computer Science"
    @State private var professor = ""
    @State private var semester = "Spring 2026"
    @State private var credits = 3
    @State private var selectedDays: Set<String> = []
    @State private var meetingTime = ""
    
    private let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Information")) {
                    TextField("Course Code (e.g., CS 101)", text: $courseCode)
                        .autocapitalization(.allCharacters)
                    
                    TextField("Course Name", text: $courseName)
                    
                    Picker("Department", selection: $department) {
                        ForEach(Department.allCases, id: \.self) { dept in
                            Text(dept.rawValue).tag(dept.rawValue)
                        }
                    }
                    
                    TextField("Professor (optional)", text: $professor)
                    
                    Picker("Semester", selection: $semester) {
                        ForEach(Semester.allCases, id: \.self) { sem in
                            Text(sem.rawValue).tag(sem.rawValue)
                        }
                    }
                    
                    Stepper("Credits: \(credits)", value: $credits, in: 1...6)
                }
                
                Section(header: Text("Schedule (Optional)")) {
                    ForEach(weekDays, id: \.self) { day in
                        Toggle(day, isOn: Binding(
                            get: { selectedDays.contains(day) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDays.insert(day)
                                } else {
                                    selectedDays.remove(day)
                                }
                            }
                        ))
                    }
                    
                    TextField("Meeting Time (e.g., 10:00 AM - 11:20 AM)", text: $meetingTime)
                }
            }
            .navigationTitle("Add Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addCourse()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !courseCode.isEmpty && !courseName.isEmpty
    }
    
    private func addCourse() {
        let newCourse = Course(
            courseCode: courseCode,
            courseName: courseName,
            department: department,
            professor: professor.isEmpty ? nil : professor,
            semester: semester,
            meetingDays: selectedDays.isEmpty ? nil : Array(selectedDays).sorted(),
            meetingTime: meetingTime.isEmpty ? nil : meetingTime,
            credits: credits
        )
        
        courses.append(newCourse)
        dismiss()
    }
}

#Preview {
    MyCoursesView()
}
