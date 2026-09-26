import Foundation

/// Represents an academic course
public struct Course: Identifiable, Codable, Equatable {
    public let id: String
    public let courseCode: String
    public let courseName: String
    public let department: String
    public let professor: String?
    public let semester: String
    public let meetingDays: [String]?
    public let meetingTime: String?
    public let credits: Int
    public let createdAt: Date
    
    public var scheduleDisplay: String? {
        guard let days = meetingDays, !days.isEmpty, let time = meetingTime else { return nil }
        let daysStr = days.joined(separator: ", ")
        return "\(daysStr) \(time)"
    }
    
    public init(
        id: String = UUID().uuidString,
        courseCode: String,
        courseName: String,
        department: String,
        professor: String? = nil,
        semester: String,
        meetingDays: [String]? = nil,
        meetingTime: String? = nil,
        credits: Int,
        createdAt: Date = Date()
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
        self.createdAt = createdAt
    }
}

/// Academic department enumeration
public enum Department: String, CaseIterable, Codable {
    case computerScience = "Computer Science"
    case mathematics = "Mathematics"
    case physics = "Physics"
    case chemistry = "Chemistry"
    case biology = "Biology"
    case english = "English"
    case history = "History"
    case psychology = "Psychology"
    case economics = "Economics"
    case businessAdministration = "Business Administration"
    case engineering = "Engineering"
    case artAndDesign = "Art and Design"
    case music = "Music"
    case foreignLanguages = "Foreign Languages"
    case other = "Other"
}

/// Academic semester enumeration
public enum Semester: String, CaseIterable, Codable {
    case fall2025 = "Fall 2025"
    case spring2026 = "Spring 2026"
    case summer2026 = "Summer 2026"
    case fall2026 = "Fall 2026"
    case spring2027 = "Spring 2027"
}

/// Course section for organizing courses
public struct CourseSection: Identifiable, Codable, Equatable {
    public let id: String
    public let sectionNumber: String
    public let instructor: String
    public let meetingDays: [String]
    public let startTime: String
    public let endTime: String
    public let location: String
    public let enrollmentCap: Int
    public var currentEnrollment: Int
    
    public init(
        id: String = UUID().uuidString,
        sectionNumber: String,
        instructor: String,
        meetingDays: [String],
        startTime: String,
        endTime: String,
        location: String,
        enrollmentCap: Int,
        currentEnrollment: Int = 0
    ) {
        self.id = id
        self.sectionNumber = sectionNumber
        self.instructor = instructor
        self.meetingDays = meetingDays
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.enrollmentCap = enrollmentCap
        self.currentEnrollment = currentEnrollment
    }
}
