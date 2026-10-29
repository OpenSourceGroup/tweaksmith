// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Tweaksmith",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "TweaksmithCore", targets: ["TweaksmithCore"]),
        .executable(name: "Tweaksmith", targets: ["TweaksmithApp"])
    ],
    targets: [
        .target(
            name: "TweaksmithCore",
            path: "Tweaksmith/Core"
        ),
        .executableTarget(
            name: "TweaksmithApp",
            dependencies: ["TweaksmithCore"],
            path: "Tweaksmith",
            exclude: ["Core"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TweaksmithCoreTests",
            dependencies: ["TweaksmithCore"],
            path: "Tests/TweaksmithCoreTests"
        ),
        // CLT hosts lack XCTest; CI macOS with Xcode uses swift test; local uses smoke.
        .executableTarget(
            name: "TweaksmithCoreSmoke",
            dependencies: ["TweaksmithCore"],
            path: "Tests/TweaksmithCoreSmoke"
        )
    ]
)
