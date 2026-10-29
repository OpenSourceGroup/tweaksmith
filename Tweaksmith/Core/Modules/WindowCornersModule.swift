import Foundation

/// Window corner radius via undocumented `NSConvolutionOverride1` (float).
///
/// Validation (2026-10-29, Apple Silicon host):
/// - `NSConvolutionOverride1` present in `.GlobalPreferences` as float (observed value 6.0).
/// - `NSConvolutionOverride2` NOT present — do not expose in UI until independently validated.
///
/// Applying may require restarting apps / logging out for full effect. Preview in-app is illustrative only.
public struct WindowCornersModule: TweakModule {
    public static let override1KeyName = "NSConvolutionOverride1"
    /// Investigated; not exposed until validated on target OS.
    public static let override2KeyName = "NSConvolutionOverride2"

    public let id = "window-corners"
    public let title = "Window Corners"
    public let category = "Appearance"
    public let status: ModuleStatus = .available
    public let summary = "Adjust macOS window corner radius using NSConvolutionOverride1."
    public let minimumMacOSMajor = 26
    public let compatibilityRisk: CompatibilityRisk = .medium
    public let compatibilityNotes: [String] = [
        "Uses undocumented preference NSConvolutionOverride1 (float).",
        "NSConvolutionOverride2 was not found on validation host — not exposed.",
        "Changes may require quitting apps or logging out to fully apply.",
        "In-app preview is illustrative only — not a live window chrome render.",
        "Always reversible via Restore Previous / Original / Reset to macOS Default."
    ]

    public let domain: PreferenceDomain

    public init(domain: PreferenceDomain = .global) {
        self.domain = domain
    }

    public var preferenceKeys: [PreferenceKey] {
        [PreferenceKey(domain: domain, name: Self.override1KeyName)]
    }

    public enum Preset: String, CaseIterable, Sendable, Identifiable {
        case systemDefault
        case sharp4
        case subtle8
        case classic10
        case custom

        public var id: String { rawValue }

        public var title: String {
            switch self {
            case .systemDefault: return "System Default"
            case .sharp4: return "Sharp (4)"
            case .subtle8: return "Subtle (8)"
            case .classic10: return "Classic (10)"
            case .custom: return "Custom"
            }
        }

        /// nil means delete key (system default).
        public var radius: Double? {
            switch self {
            case .systemDefault: return nil
            case .sharp4: return 4
            case .subtle8: return 8
            case .classic10: return 10
            case .custom: return nil
            }
        }
    }

    public func readDesired(from backend: PreferenceBackend) throws -> [PreferenceEntry] {
        try preferenceKeys.map { try backend.read($0) }
    }

    public func plan(preset: Preset, customRadius: Double? = nil) -> ApplyPlan {
        let key = preferenceKeys[0]
        let entry: PreferenceEntry
        switch preset {
        case .systemDefault:
            entry = PreferenceEntry(key: key, value: .null, existed: false)
        case .custom:
            let r = customRadius ?? 8
            entry = PreferenceEntry(key: key, value: .double(r), existed: true)
        default:
            entry = PreferenceEntry(key: key, value: .double(preset.radius!), existed: true)
        }
        return ApplyPlan(moduleID: id, desired: [entry], label: "Window Corners — \(preset.title)")
    }

    public static func override2ValidationNote() -> String {
        "NSConvolutionOverride2 was absent from GlobalPreferences on the bootstrap validation host (2026-10-29). Do not expose in UI until confirmed on macOS Tahoe 26+ with documented effect."
    }
}
