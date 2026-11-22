// swift-tools-version: 6.0
// SwiftPM manifest for building on Linux with xtool (`xtool dev`). Xcode users open DeadlineRadar.xcodeproj instead.
import PackageDescription

let package = Package(
    name: "DeadlineRadar",
    platforms: [.iOS(.v17)],
    products: [.library(name: "DeadlineRadar", targets: ["DeadlineRadar"])],
    targets: [
        .target(
            name: "DeadlineRadar",
            path: "DeadlineRadar",
            exclude: ["Assets.xcassets"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
