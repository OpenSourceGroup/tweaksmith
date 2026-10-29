import AppKit
import Foundation
import SwiftUI
import TweaksmithCore

@MainActor
public final class AppModel: ObservableObject {
    public enum Section: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case appearance = "Appearance"
        case finder = "Finder"
        case dockDesktop = "Dock & Desktop"
        case screenshots = "Screenshots"
        case productivity = "Productivity"
        case developer = "Developer"
        case advanced = "Advanced"
        case support = "Support Tweaksmith"
        case about = "About"

        public var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .overview: return "square.grid.2x2"
            case .appearance: return "paintbrush"
            case .finder: return "folder"
            case .dockDesktop: return "dock.rectangle"
            case .screenshots: return "camera.viewfinder"
            case .productivity: return "bolt.horizontal"
            case .developer: return "chevron.left.forwardslash.chevron.right"
            case .advanced: return "gearshape.2"
            case .support: return "heart"
            case .about: return "info.circle"
            }
        }
    }

    @Published var section: Section = .overview
    @Published var engineEvents: [EngineEvent] = []
    @Published var supportSheetPresented = false
    @Published var statusMessage: String?
    @Published var windowCornersRadius: Double = 8
    @Published var windowCornersPreset: WindowCornersModule.Preset = .subtle8
    @Published var lastExternalChanges: [SettingsEngine.ExternalChange] = []

    let engine: SettingsEngine
    let registry: ModuleRegistry
    let support: SupportPromptController
    let windowCorners: WindowCornersModule
    let historyDirectory: URL

    public init(useIsolatedDomainForSafety: Bool = false) {
        let fm = FileManager.default
        let supportDir = (try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fm.temporaryDirectory
        let root = supportDir.appendingPathComponent("Tweaksmith", isDirectory: true)
        try? fm.createDirectory(at: root, withIntermediateDirectories: true)
        self.historyDirectory = root.appendingPathComponent("History", isDirectory: true)

        let domain: PreferenceDomain = useIsolatedDomainForSafety
            ? .suite("co.in.kamyab.tweaksmith.preview")
            : .global

        let backend = UserDefaultsPreferenceBackend(forbidGlobalDomain: false)
        let history = try! FileHistoryStore(directory: historyDirectory)
        self.engine = SettingsEngine(backend: backend, history: history)
        self.windowCorners = WindowCornersModule(domain: domain)
        self.registry = ModuleRegistry(modules: [windowCorners])

        let appDefaults = UserDefaults(suiteName: "co.in.kamyab.tweaksmith") ?? .standard
        self.support = SupportPromptController(defaults: appDefaults)

        refreshFromSystem()
        maybeOfferSupport()
    }

    func refreshFromSystem() {
        do {
            let entries = try engine.read(windowCorners.preferenceKeys)
            if let value = entries.first?.value.doubleValue {
                windowCornersRadius = value
                windowCornersPreset = presetMatching(value)
            } else {
                windowCornersPreset = .systemDefault
            }
            try engine.adoptCurrentAsKnown(windowCorners.preferenceKeys)
            engineEvents = engine.recentEvents()
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func presetMatching(_ value: Double) -> WindowCornersModule.Preset {
        for p in WindowCornersModule.Preset.allCases {
            if let r = p.radius, abs(r - value) < 0.01 { return p }
        }
        return .custom
    }

    func applyWindowCorners() {
        do {
            if windowCornersPreset == .custom,
               WindowCornersModule.sanitiseRadius(windowCornersRadius) == nil {
                statusMessage = "Invalid corner radius. Enter a finite value between \(Int(WindowCornersModule.minRadius)) and \(Int(WindowCornersModule.maxRadius))."
                return
            }
            let report = CompatibilityChecker().evaluate(
                moduleID: windowCorners.id,
                minimumMajor: windowCorners.minimumMacOSMajor,
                risk: windowCorners.compatibilityRisk,
                notes: windowCorners.compatibilityNotes
            )
            let plan = windowCorners.plan(
                preset: windowCornersPreset,
                customRadius: windowCornersPreset == .custom ? windowCornersRadius : nil
            )
            if !report.allowed {
                statusMessage = "Compatibility warning: \(report.notes.joined(separator: " "))"
            }
            let result = try engine.apply(plan, requireCompatibility: nil)
            guard result.verified else {
                statusMessage = "Apply wrote values but verification failed — use Restore Previous."
                engineEvents = engine.recentEvents()
                return
            }
            support.recordSuccessfulAction()
            statusMessage = "Applied \(windowCornersPreset.title). Restart apps or log out for full effect. Preview is illustrative only."
            engineEvents = engine.recentEvents()
            maybeOfferSupport()
        } catch {
            statusMessage = "Apply failed: \(error.localizedDescription)"
            engineEvents = engine.recentEvents()
        }
    }

    func restorePrevious() {
        do {
            try engine.restorePrevious(keys: windowCorners.preferenceKeys, moduleID: windowCorners.id)
            refreshFromSystem()
            statusMessage = "Restored previous values."
        } catch { statusMessage = error.localizedDescription }
    }

    func restoreOriginal() {
        do {
            try engine.restoreOriginal(keys: windowCorners.preferenceKeys, moduleID: windowCorners.id)
            refreshFromSystem()
            statusMessage = "Restored original captured values."
        } catch { statusMessage = error.localizedDescription }
    }

    func resetDefault() {
        do {
            try engine.resetToMacOSDefault(keys: windowCorners.preferenceKeys, moduleID: windowCorners.id)
            refreshFromSystem()
            statusMessage = "Reset to macOS default (key removed)."
        } catch { statusMessage = error.localizedDescription }
    }

    func checkExternalChanges() {
        do {
            lastExternalChanges = try engine.detectExternalChanges(keys: windowCorners.preferenceKeys)
            if lastExternalChanges.isEmpty {
                statusMessage = "No external changes detected for tracked keys."
            } else {
                statusMessage = "External changes detected on \(lastExternalChanges.count) key(s)."
            }
        } catch { statusMessage = error.localizedDescription }
    }

    func openSupportInBrowser() {
        NSWorkspace.shared.open(SupportPromptController.supportURL)
    }

    private func maybeOfferSupport() {
        if case .show = support.decision(isManualOpen: false) {
            support.markPromptShown()
            supportSheetPresented = true
        }
    }
}
