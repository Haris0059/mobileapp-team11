import SwiftUI

/// Home: one place for what matters today: the week, next deadlines, this month and a weekly summary.
struct HomeView: View {
    private let deadlines = MockData.deadlines.sorted { $0.due < $1.due }
    @State private var selectedDay = Calendar.current.startOfDay(for: .now)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                WeekStrip(selected: $selectedDay, deadlines: deadlines)

                section("Next deadlines") {
                    VStack(spacing: 10) {
                        ForEach(deadlines.prefix(4)) { DeadlineRow(deadline: $0) }
                    }
                }

                section("This week") {
                    HStack(spacing: 10) {
                        StatTile(value: "\(deadlines.filter { $0.urgency != .later }.count)", label: "Due")
                        StatTile(value: "\(Set(deadlines.map(\.course)).count)", label: "Courses")
                        StatTile(value: "2", label: "Done")
                    }
                }

                section(Date.now.formatted(.dateTime.month(.wide).year())) {
                    MonthGrid(deadlines: deadlines)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(RadarBackground())
        .foregroundStyle(Theme.text)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today").font(.largeTitle.bold()).tracking(-0.5)
                Text("\(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))) · \(deadlines.filter { $0.urgency != .later }.count) due this week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            RadarMark().frame(width: 34)
        }
        .padding(.top, 8)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            content()
        }
    }
}

// MARK: - Week strip

private struct WeekStrip: View {
    @Binding var selected: Date
    let deadlines: [Deadline]
    private let calendar = Calendar.current

    private var days: [Date] {
        let start = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        HStack(spacing: 6) {
                ForEach(days, id: \.self) { day in
                    let isSelected = calendar.isDate(day, inSameDayAs: selected)
                    let hasDeadline = deadlines.contains { calendar.isDate($0.due, inSameDayAs: day) }
                    Button {
                        withAnimation(.spring(duration: 0.3, bounce: 0)) { selected = day }
                    } label: {
                        VStack(spacing: 3) {
                            Text(day.formatted(.dateTime.weekday(.narrow))).font(.caption2).opacity(0.7)
                            Text(day.formatted(.dateTime.day())).font(.callout.weight(.semibold))
                            Circle().fill(hasDeadline ? Theme.urgent : .clear).frame(width: 4, height: 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(isSelected ? Theme.onAmber : Theme.text)
                        .background {
                            if isSelected { RoundedRectangle(cornerRadius: 12).fill(Theme.amber) }
                        }
                        .glass(in: .rect(cornerRadius: 12), enabled: !isSelected)
                    }
                    .buttonStyle(.plain)
                }
        }
    }
}

// MARK: - Deadline row

struct DeadlineRow: View {
    let deadline: Deadline

    private var color: Color {
        switch deadline.urgency {
        case .today: Theme.urgent
        case .thisWeek: Theme.amber
        case .later: Theme.ink.opacity(0.3)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Capsule().fill(color).frame(width: 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(deadline.title).font(.body.weight(.semibold))
                Text("\(deadline.course) · \(deadline.due.formatted(.dateTime.weekday(.abbreviated).hour().minute()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(deadline.countdown)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.2), in: .capsule)
                .foregroundStyle(deadline.urgency == .today ? Theme.urgent : Theme.text)
        }
        .fixedSize(horizontal: false, vertical: true)
        .glassCard(padding: 12)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Stats

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title.bold()).monospacedDigit()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .glassCard(padding: 12)
    }
}

// MARK: - Month grid

private struct MonthGrid: View {
    let deadlines: [Deadline]
    private let calendar = Calendar.current

    /// nil = empty cell before the 1st of the month.
    private var cells: [Int?] {
        guard let month = calendar.dateInterval(of: .month, for: .now),
              let count = calendar.range(of: .day, in: .month, for: .now)?.count else { return [] }
        let lead = (calendar.component(.weekday, from: month.start) - calendar.firstWeekday + 7) % 7
        return Array(repeating: nil, count: lead) + (1...count).map { $0 }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private func hasDeadline(on day: Int) -> Bool {
        deadlines.contains {
            calendar.isDate($0.due, equalTo: .now, toGranularity: .month) && calendar.component(.day, from: $0.due) == day
        }
    }

    var body: some View {
        let today = calendar.component(.day, from: .now)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        VStack(spacing: 8) {
            HStack {
                ForEach(weekdaySymbols.indices, id: \.self) { i in
                    Text(weekdaySymbols[i]).font(.caption2.weight(.semibold)).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(cells.indices, id: \.self) { i in
                    if let day = cells[i] {
                        VStack(spacing: 2) {
                            Text("\(day)")
                                .font(.footnote.weight(day == today ? .bold : .regular))
                                .frame(width: 28, height: 28)
                                .foregroundStyle(day == today ? Theme.onAmber : Theme.text)
                                .background(day == today ? Theme.amber : .clear, in: .circle)
                            Circle().fill(hasDeadline(on: day) ? Theme.urgent : .clear).frame(width: 4, height: 4)
                        }
                    } else {
                        Color.clear.frame(height: 34)
                    }
                }
            }
        }
        .glassCard()
    }
}

#Preview("Light") { HomeView() }
#Preview("Dark") { HomeView().preferredColorScheme(.dark) }
