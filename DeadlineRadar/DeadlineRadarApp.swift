import SwiftUI

@main
struct DeadlineRadarApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Bottom navigation. On iOS 26 the system tab bar is a floating Liquid Glass bar; on iOS 17–18 it is the classic bar.
struct RootView: View {
    /// Launch argument `-tab chat` opens a tab directly (used by CI screenshots).
    @State private var tab = UserDefaults.standard.string(forKey: "tab") ?? "home"

    var body: some View {
        TabView(selection: $tab) {
            HomeView().tabItem { Label("Home", systemImage: "house") }.tag("home")
            ChatView().tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }.tag("chat")
            ProfileView().tabItem { Label("Profile", systemImage: "person.crop.circle") }.tag("profile")
        }
        .tint(Theme.ink)
    }
}

#Preview("Light") { RootView() }
#Preview("Dark") { RootView().preferredColorScheme(.dark) }
