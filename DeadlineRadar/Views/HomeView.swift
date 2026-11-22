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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                if let next = open.first {
                    NextUpCard(deadline: next) { markDone(next) }
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))
                        .id(next.id)
                } else {
                    Text("All caught up. Nothing due.")
                        .font(.title3.weight(.semibold))
                        .glassCard(cornerRadius: 26, padding: 20)
                }

                WeekStrip(selected: $selectedDay, deadlines: open)

                VStack(alignment: .leading, spacing: 10) {
                    Text(selectedDay?.formatted(.dateTime.weekday(.wide).day().month(.wide)) ?? "After that")
                        .font(.headline)
                    if listed.isEmpty {
                        Text(selectedDay == nil ? "Nothing else coming up." : "Nothing due this day.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        DeadlineList(deadlines: listed)
                    }
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
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today").font(.largeTitle.bold()).tracking(-0.5)
                Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            RadarMark().frame(width: 34)
        }
        .padding(.top, 8)
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
            HStack {
                Text("NEXT UP").font(.caption.weight(.semibold)).tracking(1.2).foregroundStyle(.secondary)
                Spacer()
                Text(deadline.course)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.ink.opacity(0.1), in: .capsule)
            }

            Text(deadline.title).font(.title2.bold()).padding(.top, 4)

            TimelineView(.periodic(from: .now, by: 60)) { _ in
                Text(deadline.countdown(long: true))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .tracking(-1)
                    .foregroundStyle(deadline.urgency == .today ? Theme.urgent : Theme.text)
                    .contentTransition(.numericText())
            }

            Text("Due \(deadline.due.formatted(.dateTime.weekday(.wide).hour().minute()))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onDone) {
                Label("Mark done", systemImage: "checkmark")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .foregroundStyle(Theme.onAmber)
                    .background(Theme.amber, in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
        .glassCard(cornerRadius: 26, padding: 20)
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
        HStack(spacing: 6) {
            ForEach(days, id: \.self) { day in
                let isSelected = selected.map { calendar.isDate(day, inSameDayAs: $0) } ?? false
                let count = deadlines.filter { calendar.isDate($0.due, inSameDayAs: day) }.count
                Button {
                    withAnimation(.spring(duration: 0.3, bounce: 0)) { selected = isSelected ? nil : day }
                } label: {
                    VStack(spacing: 3) {
                        Text(day.formatted(.dateTime.weekday(.narrow))).font(.caption2).opacity(0.7)
                        Text(day.formatted(.dateTime.day())).font(.callout.weight(.semibold))
                        Circle().fill(count > 0 ? Theme.urgent : .clear).frame(width: 4, height: 4)
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
                .accessibilityLabel("\(day.formatted(.dateTime.weekday(.wide).day().month())), \(count) due")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

// MARK: - List

private struct DeadlineList: View {
    let deadlines: [Deadline]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(deadlines.enumerated()), id: \.element.id) { index, deadline in
                if index > 0 { Divider().padding(.leading, 34) }
                DeadlineRow(deadline: deadline)
            }
        }
        .glassCard(padding: 4)
    }
}

struct DeadlineRow: View {
    let deadline: Deadline

    private var color: Color {
        switch deadline.urgency {
        case .today: Theme.urgent
        case .thisWeek: Theme.amber
        case .later: Theme.ink.opacity(0.25)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(color).frame(width: 8, height: 8)
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
                .foregroundStyle(deadline.urgency == .today ? Theme.urgent : .secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") { HomeView() }
#Preview("Dark") { HomeView().preferredColorScheme(.dark) }
