import Foundation

/// Abstraction over preference storage so production can use CFPreferences / UserDefaults
/// while tests use isolated suites and never touch the host global domain.
public protocol PreferenceBackend: Sendable {
    func read(_ key: PreferenceKey) throws -> PreferenceEntry
    func write(_ key: PreferenceKey, value: PreferenceValue) throws
    func remove(_ key: PreferenceKey) throws
    func synchronize(_ domain: PreferenceDomain) throws
}

public final class UserDefaultsPreferenceBackend: PreferenceBackend, @unchecked Sendable {
    private let lock = NSLock()
    /// When true, attempts to touch `.global` throw — used by CI / tests as a safety net.
    public let forbidGlobalDomain: Bool

    public init(forbidGlobalDomain: Bool = false) {
        self.forbidGlobalDomain = forbidGlobalDomain
    }

    public func read(_ key: PreferenceKey) throws -> PreferenceEntry {
        try guardDomain(key.domain)
        let defaults = try defaults(for: key.domain)
        lock.lock(); defer { lock.unlock() }
        if let raw = defaults.object(forKey: key.name), let value = PreferenceValue(any: raw) {
            return PreferenceEntry(key: key, value: value, existed: true)
        }
        return PreferenceEntry(key: key, value: .null, existed: false)
    }

    public func write(_ key: PreferenceKey, value: PreferenceValue) throws {
        try guardDomain(key.domain)
        let defaults = try defaults(for: key.domain)
        lock.lock(); defer { lock.unlock() }
        switch value {
        case .null:
            defaults.removeObject(forKey: key.name)
        default:
            guard let obj = value.anyObject else {
                defaults.removeObject(forKey: key.name)
                return
            }
            defaults.set(obj, forKey: key.name)
        }
    }

    public func remove(_ key: PreferenceKey) throws {
        try guardDomain(key.domain)
        let defaults = try defaults(for: key.domain)
        lock.lock(); defer { lock.unlock() }
        defaults.removeObject(forKey: key.name)
    }

    public func synchronize(_ domain: PreferenceDomain) throws {
        try guardDomain(domain)
        let defaults = try defaults(for: domain)
        lock.lock(); defer { lock.unlock() }
        _ = defaults.synchronize()
    }

    private func guardDomain(_ domain: PreferenceDomain) throws {
        if forbidGlobalDomain, case .global = domain {
            throw SettingsEngineError.keyNotAllowed(
                "Global domain writes are forbidden in this backend configuration (tests/CI)."
            )
        }
    }

    private func defaults(for domain: PreferenceDomain) throws -> UserDefaults {
        switch domain {
        case .global:
            return .standard
        case .suite(let name):
            guard let suite = UserDefaults(suiteName: name) else {
                throw SettingsEngineError.backendFailure("Unable to open suite \(name)")
            }
            return suite
        case .application(let bundleID):
            guard let suite = UserDefaults(suiteName: bundleID) else {
                throw SettingsEngineError.backendFailure("Unable to open application domain \(bundleID)")
            }
            return suite
        }
    }
}

/// In-memory backend for unit tests — never touches disk preferences.
public final class InMemoryPreferenceBackend: PreferenceBackend, @unchecked Sendable {
    private var store: [String: [String: PreferenceValue]] = [:]
    private let lock = NSLock()

    public init() {}

    public func read(_ key: PreferenceKey) throws -> PreferenceEntry {
        lock.lock(); defer { lock.unlock() }
        if let value = store[key.domain.identifier]?[key.name] {
            return PreferenceEntry(key: key, value: value, existed: true)
        }
        return PreferenceEntry(key: key, value: .null, existed: false)
    }

    public func write(_ key: PreferenceKey, value: PreferenceValue) throws {
        lock.lock(); defer { lock.unlock() }
        var domain = store[key.domain.identifier] ?? [:]
        if case .null = value {
            domain.removeValue(forKey: key.name)
        } else {
            domain[key.name] = value
        }
        store[key.domain.identifier] = domain
    }

    public func remove(_ key: PreferenceKey) throws {
        try write(key, value: .null)
    }

    public func synchronize(_ domain: PreferenceDomain) throws {}
}
