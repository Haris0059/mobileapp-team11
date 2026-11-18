import Foundation

// UI-only prototype: everything here is fake data. Moodle/iCal sync and the AI backend come later.

struct Deadline: Identifiable {
    let id = UUID()
    let title: String
    let course: String
    let due: Date

    enum Urgency { case today, thisWeek, later }

    var urgency: Urgency {
        let hours = due.timeIntervalSinceNow / 3600
        if hours < 24 { return .today }
        if hours < 24 * 7 { return .thisWeek }
        return .later
    }

    /// Short countdown such as "5h" or "3d".
    var countdown: String {
        let hours = max(0, Int(due.timeIntervalSinceNow / 3600))
        return hours < 24 ? "\(hours)h" : "\(hours / 24)d"
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let fromUser: Bool
}

enum MockData {
    private static func inHours(_ h: Double) -> Date { Date().addingTimeInterval(h * 3600) }

    static let deadlines: [Deadline] = [
        Deadline(title: "Database schema", course: "IT 3002", due: inHours(5)),
        Deadline(title: "Kick-off pack", course: "IT 3002", due: inHours(50)),
        Deadline(title: "Quiz 3", course: "Mathematics", due: inHours(110)),
        Deadline(title: "Essay draft", course: "English", due: inHours(190)),
        Deadline(title: "Lab report", course: "Physics", due: inHours(240)),
        Deadline(title: "Milestone 1 presentation", course: "IT 3002", due: inHours(330)),
    ]

    static let chat: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm Radar. Once connected to Moodle I can answer questions about your courses and deadlines.", fromUser: false),
        ChatMessage(text: "What's due this week?", fromUser: true),
        ChatMessage(text: "You have 3 deadlines this week. The closest is the IT 3002 database schema, due in 5 hours.", fromUser: false),
    ]

    static let suggestions = ["What's due this week?", "Summarise IT 3002", "When is my next quiz?"]
}
