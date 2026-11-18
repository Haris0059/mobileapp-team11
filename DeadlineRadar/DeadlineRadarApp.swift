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
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") { HomeView() }
            Tab("Chat", systemImage: "bubble.left.and.text.bubble.right.fill") { ChatView() }
            Tab("Profile", systemImage: "person.crop.circle.fill") { ProfileView() }
        }
        .tint(Theme.activeTab)
    }
}

#Preview("Light") { RootView() }
#Preview("Dark") { RootView().preferredColorScheme(.dark) }
