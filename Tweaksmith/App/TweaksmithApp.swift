import SwiftUI
import TweaksmithCore

@main
struct TweaksmithApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup("Tweaksmith") {
            RootView()
                .environmentObject(appModel)
                .frame(minWidth: 880, minHeight: 560)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
