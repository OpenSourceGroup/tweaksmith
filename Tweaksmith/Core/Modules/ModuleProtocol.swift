import Foundation

public enum ModuleStatus: String, Codable, Sendable {
    case available
    case planned
    case experimental
}

public protocol TweakModule: Sendable {
    var id: String { get }
    var title: String { get }
    var category: String { get }
    var status: ModuleStatus { get }
    var summary: String { get }
    var preferenceKeys: [PreferenceKey] { get }
    var minimumMacOSMajor: Int { get }
    var compatibilityRisk: CompatibilityRisk { get }
    var compatibilityNotes: [String] { get }

    func readDesired(from backend: PreferenceBackend) throws -> [PreferenceEntry]
}

public struct ModuleRegistry: Sendable {
    public let modules: [any TweakModule]

    public init(modules: [any TweakModule]) {
        self.modules = modules
    }

    public func module(id: String) -> (any TweakModule)? {
        modules.first { $0.id == id }
    }

    public func modules(in category: String) -> [any TweakModule] {
        modules.filter { $0.category == category }
    }

    public static func production(domain: PreferenceDomain = .global) -> ModuleRegistry {
        ModuleRegistry(modules: [
            WindowCornersModule(domain: domain)
        ])
    }

    public static func plannedCatalog() -> [(id: String, title: String, category: String, status: ModuleStatus)] {
        [
            ("window-corners", "Window Corners", "Appearance", .available),
            ("finder-path-bar", "Finder Path Bar", "Finder", .planned),
            ("dock-autohide-speed", "Dock Autohide Speed", "Dock & Desktop", .planned),
            ("screenshot-location", "Screenshot Location", "Screenshots", .planned),
            ("key-repeat", "Key Repeat", "Productivity", .planned),
            ("show-hidden-files", "Show Hidden Files", "Developer", .planned),
            ("advanced-defaults", "Advanced Defaults", "Advanced", .planned)
        ]
    }
}
