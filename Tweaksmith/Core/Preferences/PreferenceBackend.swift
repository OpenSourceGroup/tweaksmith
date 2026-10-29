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
        lock.lock(); defer { lock.unlock() }
        if case .global = key.domain {
            // NSGlobalDomain via CFPreferences — never UserDefaults.standard (app domain).
            if let raw = CFPreferencesCopyAppValue(key.name as CFString, kCFPreferencesAnyApplication) {
                if let value = PreferenceValue(any: raw) {
                    return PreferenceEntry(key: key, value: value, existed: true)
                }
            }
            return PreferenceEntry(key: key, value: .null, existed: false)
        }
        let defaults = try defaults(for: key.domain)
        if let raw = defaults.object(forKey: key.name), let value = PreferenceValue(any: raw) {
            return PreferenceEntry(key: key, value: value, existed: true)
        }
        return PreferenceEntry(key: key, value: .null, existed: false)
    }

    public func write(_ key: PreferenceKey, value: PreferenceValue) throws {
        try guardDomain(key.domain)
        lock.lock(); defer { lock.unlock() }
        if case .global = key.domain {
            switch value {
            case .null:
                CFPreferencesSetAppValue(key.name as CFString, nil, kCFPreferencesAnyApplication)
            default:
                guard let obj = value.anyObject else {
                    CFPreferencesSetAppValue(key.name as CFString, nil, kCFPreferencesAnyApplication)
                    return
                }
                CFPreferencesSetAppValue(key.name as CFString, obj as CFPropertyList, kCFPreferencesAnyApplication)
            }
            return
        }
        let defaults = try defaults(for: key.domain)
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
        lock.lock(); defer { lock.unlock() }
        if case .global = key.domain {
            CFPreferencesSetAppValue(key.name as CFString, nil, kCFPreferencesAnyApplication)
            return
        }
        let defaults = try defaults(for: key.domain)
        defaults.removeObject(forKey: key.name)
    }

    public func synchronize(_ domain: PreferenceDomain) throws {
        try guardDomain(domain)
        lock.lock(); defer { lock.unlock() }
        if case .global = domain {
            // Flush NSGlobalDomain to disk so `defaults read -g` and other processes see it.
            _ = CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
            return
        }
        let defaults = try defaults(for: domain)
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
            // Unreachable — callers use CFPreferences for `.global`. Kept to fail loudly if misused.
            throw SettingsEngineError.backendFailure(
                "NSGlobalDomain must use CFPreferences (kCFPreferencesAnyApplication), not UserDefaults.standard"
            )
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
