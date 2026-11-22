import Foundation

// UI-only prototype: everything here is fake data. Moodle/iCal sync and the AI backend come later.

struct Deadline: Identifiable {
    let id = UUID()
    let title: String
    let course: String
    let due: Date
    var isDone = false

    enum Urgency { case today, thisWeek, later }

    var urgency: Urgency {
        let hours = due.timeIntervalSinceNow / 3600
        if hours < 24 { return .today }
        if hours < 24 * 7 { return .thisWeek }
        return .later
    }

    /// "45m", "6h", "3d" for lists; "6h 12m", "2d 9h" when `long`.
    func countdown(long: Bool = false) -> String {
        let minutes = max(0, Int(due.timeIntervalSinceNow / 60))
        let (d, h, m) = (minutes / 1440, minutes % 1440 / 60, minutes % 60)
        if d > 0 { return long ? "\(d)d \(h)h" : "\(d)d" }
        if h > 0 { return long ? "\(h)h \(m)m" : "\(h)h" }
        return "\(m)m"
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let fromUser: Bool
}

enum MockData {
    /// Today + `days`, at a fixed clock time, like real deadlines (23:59, 09:00, start of class).
    private static func day(_ days: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: .now)) ?? .now
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }

    static let deadlines: [Deadline] = [
        Deadline(title: "Database schema", course: "IT 3002", due: day(0, 23, 59)),
        Deadline(title: "Lab 7 kick-off pack", course: "IT 3002", due: day(2, 9)),
        Deadline(title: "Quiz 3: Integrals", course: "MATH 2101", due: day(4, 10, 15)),
        Deadline(title: "Essay first draft", course: "ENG 1002", due: day(6, 23, 59)),
        Deadline(title: "Lab report 5", course: "PHY 1201", due: day(9, 17)),
        Deadline(title: "Milestone 1 presentation", course: "IT 3002", due: day(13, 9)),
    ]

    static let student = (name: "Lejla Kovačević", initials: "LK", programme: "Information Technology · Year 3")

    static let chat: [ChatMessage] = [
        ChatMessage(text: "Hi Lejla, I'm Bit! Once I'm connected to Moodle I can answer questions about your courses and deadlines.", fromUser: false),
        ChatMessage(text: "What should I work on first?", fromUser: true),
        ChatMessage(text: "The IT 3002 database schema is due tonight at 23:59. After that, the kick-off pack is due in two days at 09:00.", fromUser: false),
    ]

    static let suggestions = ["What should I work on first?", "Summarise IT 3002", "When is my next quiz?"]
}
