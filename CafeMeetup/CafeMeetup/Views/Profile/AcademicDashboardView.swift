import SwiftUI

/// Academic Progress Dashboard - Tracks study productivity metrics
/// Emphasizes ACADEMIC ACHIEVEMENT over dating metrics
struct AcademicDashboardView: View {
    @State private var studyStats = StudyStatistics()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Study Hours
                    AcademicStatCard(
                        title: "Study Hours This Week",
                        value: "\(studyStats.hoursThisWeek)",
                        subtitle: "Goal: 15 hours",
                        icon: "clock.fill",
                        color: .blue,
                        progress: Double(studyStats.hoursThisWeek) / 15.0
                    )
                    
                    // Study Streak
                    AcademicStatCard(
                        title: "Study Streak",
                        value: "\(studyStats.currentStreak) days",
                        subtitle: "Keep it going!",
                        icon: "flame.fill",
                        color: .orange,
                        progress: Double(studyStats.currentStreak) / 30.0
                    )
                    
                    // Study Sessions Grid
                    HStack(spacing: 16) {
                        MiniStatCard(
                            title: "Sessions This Week",
                            value: "\(studyStats.sessionsThisWeek)",
                            icon: "person.3.fill",
                            color: .green
                        )
                        
                        MiniStatCard(
                            title: "Total Sessions",
                            value: "\(studyStats.totalSessions)",
                            icon: "checkmark.circle.fill",
                            color: .purple
                        )
                    }
                    
                    // Courses Being Studied
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Courses Being Studied")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(studyStats.courseBreakdown, id: \.course) { item in
                                    CourseBreakdownCard(course: item.course, hours: item.hours)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Study Partners
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Most Frequent Study Partners")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(studyStats.topStudyPartners, id: \.name) { partner in
                                StudyPartnerRow(name: partner.name, sessions: partner.sessions)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Coffee Shops Visited
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Study Locations")
                                .font(.headline)
                            Spacer()
                            Text("\(studyStats.uniqueCafesVisited) cafés")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(studyStats.topCafes, id: \.name) { cafe in
                                    CafeVisitCard(name: cafe.name, visits: cafe.visits)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Weekly Goal Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Goals")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            GoalProgressRow(
                                goal: "Study 15 hours",
                                current: studyStats.hoursThisWeek,
                                target: 15,
                                icon: "clock.fill"
                            )
                            
                            GoalProgressRow(
                                goal: "Attend 5 group sessions",
                                current: studyStats.sessionsThisWeek,
                                target: 5,
                                icon: "person.3.fill"
                            )
                            
                            GoalProgressRow(
                                goal: "Study 3 different courses",
                                current: studyStats.coursesStudiedThisWeek,
                                target: 3,
                                icon: "book.fill"
                            )
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Academic Progress")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// MARK: - Supporting Views

struct AcademicStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: min(progress, 1.0))
                .tint(color)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct CourseBreakdownCard: View {
    let course: String
    let hours: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course)
                .font(.headline)
            
            Text("\(hours) hours")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 140)
        .padding()
        .background(Color.brown.opacity(0.2))
        .cornerRadius(12)
    }
}

struct StudyPartnerRow: View {
    let name: String
    let sessions: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.brown.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(name.prefix(1))
                        .font(.headline)
                        .foregroundColor(.brown)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(sessions) sessions together")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct CafeVisitCard: View {
    let name: String
    let visits: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.title2)
                .foregroundColor(.brown)
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("\(visits) visits")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 140)
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct GoalProgressRow: View {
    let goal: String
    let current: Int
    let target: Int
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.brown)
                
                Text(goal)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(current)/\(target)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(current >= target ? .green : .secondary)
            }
            
            ProgressView(value: Double(current), total: Double(target))
                .tint(current >= target ? .green : .brown)
        }
    }
}

// MARK: - Data Models

struct StudyStatistics {
    var hoursThisWeek: Int = 12
    var currentStreak: Int = 7
    var sessionsThisWeek: Int = 4
    var totalSessions: Int = 23
    var coursesStudiedThisWeek: Int = 3
    var uniqueCafesVisited: Int = 5
    
    var courseBreakdown: [(course: String, hours: Int)] = [
        ("CS 101", 5),
        ("MATH 250", 4),
        ("ENGL 102", 3)
    ]
    
    var topStudyPartners: [(name: String, sessions: Int)] = [
        ("Sarah Miller", 8),
        ("Mike Chen", 6),
        ("Emma Davis", 5)
    ]
    
    var topCafes: [(name: String, visits: Int)] = [
        ("Campus Coffee Co.", 8),
        ("Brewed Awakening", 6),
        ("The Grind", 5),
        ("Study Brew", 3),
        ("Java Junction", 1)
    ]
}

#Preview {
    AcademicDashboardView()
}
