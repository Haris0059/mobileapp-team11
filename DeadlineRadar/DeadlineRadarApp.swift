import SwiftUI

@main
struct DeadlineRadarApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Bottom navigation. On iOS 26 the system TabView is a floating Liquid Glass bar.
struct RootView: View {
    /// Launch argument `-tab chat` opens a tab directly (used by CI screenshots).
    @State private var tab = UserDefaults.standard.string(forKey: "tab") ?? "home"

    var body: some View {
        TabView(selection: $tab) {
            Tab("Home", systemImage: "house.fill", value: "home") { HomeView() }
            Tab("Chat", systemImage: "bubble.left.and.text.bubble.right.fill", value: "chat") { ChatView() }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: "profile") { ProfileView() }
        }
        .tint(Theme.activeTab)
    }
}

#Preview("Light") { RootView() }
#Preview("Dark") { RootView().preferredColorScheme(.dark) }
