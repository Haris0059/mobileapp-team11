import SwiftUI

/// Home: the one deadline that matters now, the next 7 days, and everything after it.
struct HomeView: View {
    @State private var deadlines = MockData.deadlines.sorted { $0.due < $1.due }
    /// nil = show everything upcoming; a day = show only that day.
    @State private var selectedDay: Date?
    private let calendar = Calendar.current

    private var open: [Deadline] { deadlines.filter { !$0.isDone } }

    private var listed: [Deadline] {
        guard let day = selectedDay else { return Array(open.dropFirst()) }
        return open.filter { calendar.isDate($0.due, inSameDayAs: day) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Next up") {
                    if let next = open.first {
                        NextUpCard(deadline: next) { markDone(next) }
                    } else {
                        Text("All caught up. Nothing due.").font(.headline)
                    }
                }

                Section("This week") {
                    WeekStrip(selected: $selectedDay, deadlines: open)
                        .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                }

                Section(selectedDay?.formatted(.dateTime.weekday(.wide).day().month(.wide)) ?? "After that") {
                    if listed.isEmpty {
                        Text(selectedDay == nil ? "Nothing else coming up." : "Nothing due this day.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(listed) { DeadlineRow(deadline: $0) }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Today")
            .toolbar { RadarMark().frame(width: 28) }
        }
    }

    private func markDone(_ deadline: Deadline) {
        guard let index = deadlines.firstIndex(where: { $0.id == deadline.id }) else { return }
        withAnimation(.spring(duration: 0.4, bounce: 0)) { deadlines[index].isDone = true }
    }
}

// MARK: - Next up

private struct NextUpCard: View {
    let deadline: Deadline
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(deadline.course).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
            Text(deadline.title).font(.title2.bold())

            TimelineView(.periodic(from: .now, by: 60)) { _ in
                Text(deadline.countdown(long: true))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .tracking(-1)
                    .contentTransition(.numericText())
            }

            Text("Due \(deadline.due.formatted(.dateTime.weekday(.wide).hour().minute()))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onDone) {
                Label("Mark done", systemImage: "checkmark")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Theme.amber)
            .foregroundStyle(Theme.onAmber)
            .padding(.top, 12)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Week strip (filters the list)

private struct WeekStrip: View {
    @Binding var selected: Date?
    let deadlines: [Deadline]
    private let calendar = Calendar.current

    /// Today and the next 6 days: past days are not useful here.
    private var days: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: calendar.startOfDay(for: .now)) }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(days, id: \.self) { day in
                let isSelected = selected.map { calendar.isDate(day, inSameDayAs: $0) } ?? false
                let due = deadlines.filter { calendar.isDate($0.due, inSameDayAs: day) }
                let count = due.count
                Button {
                    withAnimation(.spring(duration: 0.3, bounce: 0)) { selected = isSelected ? nil : day }
                } label: {
                    VStack(spacing: 3) {
                        Text(day.formatted(.dateTime.weekday(.narrow))).font(.caption2).opacity(0.7)
                        Text(day.formatted(.dateTime.day())).font(.callout.weight(.semibold))
                        Circle().fill(due.first.map { $0.urgency.color } ?? .clear).frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(isSelected ? Theme.onAmber : Theme.text)
                    .background(isSelected ? Theme.amber : .clear, in: .rect(cornerRadius: 12))
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(day.formatted(.dateTime.weekday(.wide).day().month())), \(count) due")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

// MARK: - Row

struct DeadlineRow: View {
    let deadline: Deadline

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(deadline.urgency.color).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(deadline.title).font(.body.weight(.medium))
                Text("\(deadline.course) · \(deadline.due.formatted(.dateTime.weekday(.abbreviated).hour().minute()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(deadline.countdown())
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") { HomeView() }
#Preview("Dark") { HomeView().preferredColorScheme(.dark) }

extension Deadline.Urgency {
    /// Red = due within 24 h, amber = this week, faded ink = later.
    var color: Color {
        switch self {
        case .today: Theme.urgent
        case .thisWeek: Theme.amber
        case .later: Theme.ink.opacity(0.25)
        }
    }
}
