import Foundation

/// Course - Represents a college course/class that students are taking
/// Used for matching study partners and organizing study sessions
struct Course: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let courseCode: String // e.g., "CS 101", "MATH 250"
    let courseName: String // e.g., "Introduction to Programming"
    let department: String // e.g., "Computer Science"
    let professor: String?
    let semester: String // e.g., "Fall 2025", "Spring 2026"
    var meetingDays: [String]? // e.g., ["Monday", "Wednesday", "Friday"]
    var meetingTime: String? // e.g., "10:00 AM - 11:20 AM"
    var credits: Int
    var grade: String? // Current or expected grade
    
    init(
        id: String = UUID().uuidString,
        courseCode: String,
        courseName: String,
        department: String,
        professor: String? = nil,
        semester: String,
        meetingDays: [String]? = nil,
        meetingTime: String? = nil,
        credits: Int = 3,
        grade: String? = nil
    ) {
        self.id = id
        self.courseCode = courseCode
        self.courseName = courseName
        self.department = department
        self.professor = professor
        self.semester = semester
        self.meetingDays = meetingDays
        self.meetingTime = meetingTime
        self.credits = credits
        self.grade = grade
    }
    
    // Display format for course
    var displayName: String {
        "\(courseCode): \(courseName)"
    }
    
    // Schedule display
    var scheduleDisplay: String? {
        guard let days = meetingDays, let time = meetingTime else { return nil }
        return "\(days.joined(separator: ", ")) at \(time)"
    }
}

/// Department categories for courses
enum Department: String, CaseIterable {
    case computerScience = "Computer Science"
    case mathematics = "Mathematics"
    case engineering = "Engineering"
    case business = "Business"
    case biology = "Biology"
    case chemistry = "Chemistry"
    case physics = "Physics"
    case psychology = "Psychology"
    case english = "English"
    case history = "History"
    case economics = "Economics"
    case art = "Art"
    case music = "Music"
    case education = "Education"
    case nursing = "Nursing"
    case politicalScience = "Political Science"
    case sociology = "Sociology"
    case communications = "Communications"
    case other = "Other"
}

/// Academic semester options
enum Semester: String, CaseIterable {
    case fall2024 = "Fall 2024"
    case spring2025 = "Spring 2025"
    case summer2025 = "Summer 2025"
    case fall2025 = "Fall 2025"
    case spring2026 = "Spring 2026"
    case summer2026 = "Summer 2026"
    
    var displayName: String { rawValue }
}

/// Days of the week for class meetings
enum WeekDay: String, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var abbreviation: String {
        String(rawValue.prefix(3))
    }
}
