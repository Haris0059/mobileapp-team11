import SwiftUI

/// Profile: who you are, which sources are connected, reminder and appearance settings. UI only, no sign-up yet.
struct ProfileView: View {
    @State private var remindThreeDays = true
    @State private var remindOneDay = true
    @State private var remindOneHour = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    identity

                    group("Sources") {
                        SourceRow(icon: "graduationcap.fill", title: "Moodle", detail: "Not connected")
                        Divider()
                        SourceRow(icon: "calendar", title: "iCal feed", detail: "Not connected")
                    }

                    group("Reminders") {
                        Toggle("3 days before", isOn: $remindThreeDays)
                        Divider()
                        Toggle("1 day before", isOn: $remindOneDay)
                        Divider()
                        Toggle("1 hour before", isOn: $remindOneHour)
                    }
                    .tint(Theme.amber)

                    group("About") {
                        LabeledContent("Version", value: "0.1 prototype")
                        Divider()
                        LabeledContent("Team", value: "IT 3002 · Team 11")
                    }
                }
                .padding(16)
            }
            .background(RadarBackground())
            .navigationTitle("Profile")
            .foregroundStyle(Theme.text)
        }
    }

    private var identity: some View {
        HStack(spacing: 14) {
            Text("ST")
                .font(.title2.bold())
                .foregroundStyle(Theme.onAmber)
                .frame(width: 64, height: 64)
                .background(Theme.amber, in: .circle)
            VStack(alignment: .leading, spacing: 2) {
                Text("Student").font(.title3.bold())
                Text("International Burch University").font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .glassCard()
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).padding(.leading, 4)
            VStack(spacing: 10) { content() }.glassCard()
        }
    }
}

private struct SourceRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.ink)
                .frame(width: 30, height: 30)
                .glass(in: .rect(cornerRadius: 8))
            Text(title)
            Spacer()
            Text(detail).font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

#Preview("Light") { ProfileView() }
#Preview("Dark") { ProfileView().preferredColorScheme(.dark) }
