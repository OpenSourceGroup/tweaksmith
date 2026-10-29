import AppKit
import Foundation
import SwiftUI
import TweaksmithCore

@MainActor
public final class AppModel: ObservableObject {
    /// Sidebar destinations — real product surfaces only (no fake placeholders).
    public enum Section: String, CaseIterable, Hashable, Identifiable {
        case tweaks
        case activity
        case support

        public var id: String { rawValue }

        var title: String {
            switch self {
            case .tweaks: return "Window Corners"
            case .activity: return "Changes"
            case .support: return "Support"
            }
        }

        var group: String {
            switch self {
            case .tweaks: return "TWEAKS"
            case .activity: return "ACTIVITY"
            case .support: return "TWEAKSMITH"
            }
        }

        var systemImage: String {
            switch self {
            case .tweaks: return "rectangle.inset.filled"
            case .activity: return "clock.arrow.circlepath"
            case .support: return "heart"
            }
        }
    }

    /// Non-optional selection with Window Corners as the only valid default.
    @Published var section: Section = .tweaks
    @Published var engineEvents: [EngineEvent] = []
    @Published var supportSheetPresented = false
    @Published var statusMessage: String?
    @Published var applyConfirmationVisible = false
    @Published var windowCornersRadius: Double = 8
    @Published var windowCornersPreset: WindowCornersModule.Preset = .subtle8
    @Published var customRadiusField: String = "8"
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

        // Dedicated suite — never use the bundle id as suiteName (NSUserDefaults warns / no-ops).
        let appDefaults = UserDefaults(suiteName: "co.in.kamyab.tweaksmith.prefs") ?? .standard
        self.support = SupportPromptController(defaults: appDefaults)

        refreshFromSystem()
        maybeOfferSupport()
    }

    /// Never leave selection invalid — always land on Window Corners.
    func ensureValidSelection() {
        if Section.allCases.contains(section) == false {
            section = .tweaks
        }
    }

    var currentRadiusDescription: String {
        if windowCornersPreset == .systemDefault {
            return "System Default"
        }
        if windowCornersPreset == .custom {
            return String(format: "Custom · %.1f", windowCornersRadius)
        }
        if let r = windowCornersPreset.radius {
            let name: String
            switch windowCornersPreset {
            case .sharp4: name = "Sharp"
            case .subtle8: name = "Subtle"
            case .classic10: name = "Classic"
            default: name = windowCornersPreset.title
            }
            return "\(name) · \(Int(r))"
        }
        return windowCornersPreset.title
    }

    var selectedRadiusDescription: String {
        currentRadiusDescription
    }

    func refreshFromSystem() {
        do {
            let entries = try engine.read(windowCorners.preferenceKeys)
            if let value = entries.first?.value.doubleValue {
                windowCornersRadius = value
                customRadiusField = String(format: "%.1f", value)
                windowCornersPreset = presetMatching(value)
            } else {
                windowCornersPreset = .systemDefault
            }
            try engine.adoptCurrentAsKnown(windowCorners.preferenceKeys)
            engineEvents = engine.recentEvents()
            lastExternalChanges = try engine.detectExternalChanges(keys: windowCorners.preferenceKeys)
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
            if windowCornersPreset == .custom {
                let parsed = Double(customRadiusField.trimmingCharacters(in: .whitespacesAndNewlines))
                guard let sanitised = WindowCornersModule.sanitiseRadius(parsed) else {
                    statusMessage = "Invalid corner radius. Enter a finite value between \(Int(WindowCornersModule.minRadius)) and \(Int(WindowCornersModule.maxRadius))."
                    return
                }
                windowCornersRadius = sanitised
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
            statusMessage = nil
            applyConfirmationVisible = true
            engineEvents = engine.recentEvents()
            lastExternalChanges = []
            maybeOfferSupport()
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                applyConfirmationVisible = false
            }
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
                statusMessage = "Changed outside Tweaksmith — values differ from last apply."
            }
        } catch { statusMessage = error.localizedDescription }
    }

    func openSupportInBrowser(amountINR: Int? = nil) {
        var url = SupportPromptController.supportURL
        if let amountINR, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var items = components.queryItems ?? []
            items.append(URLQueryItem(name: "amount", value: String(amountINR)))
            components.queryItems = items
            if let built = components.url { url = built }
        }
        NSWorkspace.shared.open(url)
    }

    func openSupportInBrowser() {
        openSupportInBrowser(amountINR: nil)
    }

    private func maybeOfferSupport() {
        if case .show = support.decision(isManualOpen: false) {
            support.markPromptShown()
            supportSheetPresented = true
        }
    }
}
