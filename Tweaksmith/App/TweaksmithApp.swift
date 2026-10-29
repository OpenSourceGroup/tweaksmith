import AppKit
import SwiftUI
import TweaksmithCore

@main
struct TweaksmithApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appModel)
                .onAppear {
                    applyLaunchOverrides()
                    scheduleOptionalSnapshot()
                }
        }
        .defaultSize(width: 900, height: 620)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {
                Button("About Tweaksmith") {
                    AboutWindowController.shared.show()
                }
            }
            CommandGroup(after: .help) {
                Button("Tweaksmith Support…") {
                    appModel.section = .support
                }
                Button("Open Source Group") {
                    NSWorkspace.shared.open(ProjectLinks.osg)
                }
            }
        }
    }

    private func applyLaunchOverrides() {
        let env = ProcessInfo.processInfo.environment
        if let raw = env["TWEAKSMITH_SECTION"]?.lowercased() {
            switch raw {
            case "tweaks", "corners", "window-corners": appModel.section = .tweaks
            case "activity", "changes": appModel.section = .activity
            case "support": appModel.section = .support
            default: appModel.section = .tweaks
            }
        }
        if env["TWEAKSMITH_PRESET"] == "subtle8" {
            appModel.windowCornersPreset = .subtle8
            appModel.windowCornersRadius = 8
        }
        if env["TWEAKSMITH_SHOW_ABOUT"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                AboutWindowController.shared.show()
            }
        }
    }

    /// Offscreen window bitmap — no Screen Recording TCC required (QA / docs only).
    private func scheduleOptionalSnapshot() {
        let env = ProcessInfo.processInfo.environment
        guard let path = env["TWEAKSMITH_SNAPSHOT_PATH"], !path.isEmpty else { return }
        let delay = Double(env["TWEAKSMITH_SNAPSHOT_DELAY"] ?? "0.8") ?? 0.8
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            WindowSnapshot.writeFrontWindow(to: path)
            if env["TWEAKSMITH_SNAPSHOT_EXIT"] == "1" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NSApp.terminate(nil)
                }
            }
        }
    }
}

@MainActor
enum WindowSnapshot {
    static func writeFrontWindow(to path: String) {
        let preferAbout = ProcessInfo.processInfo.environment["TWEAKSMITH_SHOW_ABOUT"] == "1"
        let window: NSWindow? = {
            if preferAbout {
                return NSApp.windows.first(where: { $0.title.localizedCaseInsensitiveContains("About") && $0.isVisible })
                    ?? NSApp.windows.first(where: { $0.isVisible })
            }
            return NSApp.windows.first(where: { $0.isVisible && !$0.title.localizedCaseInsensitiveContains("About") })
                ?? NSApp.mainWindow
                ?? NSApp.windows.first(where: \.isVisible)
        }()
        guard let window, let view = window.contentView else { return }
        let bounds = view.bounds
        guard let rep = view.bitmapImageRepForCachingDisplay(in: bounds) else { return }
        view.cacheDisplay(in: bounds, to: rep)
        guard let data = rep.representation(using: .png, properties: [:]) else { return }
        let url = URL(fileURLWithPath: path)
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: url)
        fputs("snapshot wrote \(path) \(Int(bounds.width))x\(Int(bounds.height)) title=\(window.title)\n", stderr)
    }
}

/// Lightweight About panel — native menu destination (not a sidebar item).
@MainActor
enum AboutWindowController {
    static let shared = AboutPanelHost()
}

@MainActor
final class AboutPanelHost {
    private var panel: NSPanel?

    func show() {
        if panel == nil {
            let hosting = NSHostingView(rootView: AboutView().frame(width: 420, height: 380))
            let p = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 380),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            p.title = "About Tweaksmith"
            p.contentView = hosting
            p.isReleasedWhenClosed = false
            p.center()
            panel = p
        }
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
