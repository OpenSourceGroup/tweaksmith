import Foundation

/// Logical preference domain. Production may use `.global` for Apple undocumented keys.
/// Tests MUST use `.suite(name:)` isolated domains — never mutate the runner's real global prefs.
public enum PreferenceDomain: Equatable, Sendable, Hashable, Codable {
    case global
    case suite(String)
    case application(String)

    public var identifier: String {
        switch self {
        case .global: return "NSGlobalDomain"
        case .suite(let name): return name
        case .application(let bundleID): return bundleID
        }
    }
}

public enum PreferenceValue: Equatable, Sendable, Codable, Hashable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case data(Data)
    case null

    public init?(any: Any?) {
        guard let any else {
            self = .null
            return
        }
        switch any {
        case let v as Bool: self = .bool(v)
        case let v as Int: self = .int(v)
        case let v as NSNumber:
            // Bool bridged as NSNumber — prefer integer/double for corner radii.
            let objCType = String(cString: v.objCType)
            if objCType == "c" || objCType == "B" {
                self = .bool(v.boolValue)
            } else if objCType == "d" || objCType == "f" {
                self = .double(v.doubleValue)
            } else {
                self = .int(v.intValue)
            }
        case let v as Double: self = .double(v)
        case let v as Float: self = .double(Double(v))
        case let v as String: self = .string(v)
        case let v as Data: self = .data(v)
        default: return nil
        }
    }

    public var anyObject: Any? {
        switch self {
        case .bool(let v): return v
        case .int(let v): return v
        case .double(let v): return v
        case .string(let v): return v
        case .data(let v): return v
        case .null: return nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case .double(let v): return v
        case .int(let v): return Double(v)
        default: return nil
        }
    }
}

public struct PreferenceKey: Equatable, Sendable, Hashable, Codable {
    public let domain: PreferenceDomain
    public let name: String

    public init(domain: PreferenceDomain, name: String) {
        self.domain = domain
        self.name = name
    }
}

public struct PreferenceEntry: Equatable, Sendable, Codable, Hashable {
    public let key: PreferenceKey
    public let value: PreferenceValue
    public let existed: Bool

    public init(key: PreferenceKey, value: PreferenceValue, existed: Bool) {
        self.key = key
        self.value = value
        self.existed = existed
    }
}

public struct PreferenceSnapshot: Equatable, Sendable, Codable {
    public let id: UUID
    public let createdAt: Date
    public let label: String
    public let reason: SnapshotReason
    public let entries: [PreferenceEntry]

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        label: String,
        reason: SnapshotReason,
        entries: [PreferenceEntry]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.label = label
        self.reason = reason
        self.entries = entries
    }
}

public enum SnapshotReason: String, Codable, Sendable {
    case preApplyBackup
    case originalCapture
    case manual
    case externalChangeDetected
    case restorePoint
}

public enum SettingsEngineError: Error, Equatable, Sendable {
    case keyNotAllowed(String)
    case backendFailure(String)
    case verificationFailed(expected: PreferenceValue, actual: PreferenceValue?)
    case snapshotNotFound(UUID)
    case noHistory
    case incompatible(String)
    case moduleUnknown(String)
    case shellNotAllowlisted(String)
}

public enum EnginePhase: String, Codable, Sendable {
    case read
    case backup
    case apply
    case verify
    case history
    case restore
    case reset
    case compatibility
    case error
}

public struct EngineEvent: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let at: Date
    public let phase: EnginePhase
    public let message: String
    public let moduleID: String?

    public init(
        id: UUID = UUID(),
        at: Date = Date(),
        phase: EnginePhase,
        message: String,
        moduleID: String? = nil
    ) {
        self.id = id
        self.at = at
        self.phase = phase
        self.message = message
        self.moduleID = moduleID
    }
}
