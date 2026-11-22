import SwiftUI

/// Profile: who you are, which sources are connected, reminder settings. UI only, no sign-up yet.
struct ProfileView: View {
    @State private var remindThreeDays = true
    @State private var remindOneDay = true
    @State private var remindOneHour = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Text(MockData.student.initials)
                            .font(.title3.bold())
                            .foregroundStyle(Theme.ink)
                            .frame(width: 56, height: 56)
                            .background(Theme.ink.opacity(0.1), in: .circle)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(MockData.student.name).font(.headline)
                            Text(MockData.student.programme).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    LabeledContent { Text("Not connected") } label: { Label("Moodle", systemImage: "graduationcap") }
                    LabeledContent { Text("Not connected") } label: { Label("iCal feed", systemImage: "calendar") }
                } header: {
                    Text("Sources")
                } footer: {
                    Text("Deadlines sync from connected sources.")
                }

                Section("Remind me") {
                    Toggle("3 days before", isOn: $remindThreeDays)
                    Toggle("1 day before", isOn: $remindOneDay)
                    Toggle("1 hour before", isOn: $remindOneHour)
                }
                .tint(Theme.amber)

                Section {
                    LabeledContent("Version", value: "0.1")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Profile")
        }
    }
}

#Preview("Light") { ProfileView() }
#Preview("Dark") { ProfileView().preferredColorScheme(.dark) }
