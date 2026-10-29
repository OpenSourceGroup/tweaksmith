import Foundation

public struct ApplyPlan: Equatable, Sendable {
    public let moduleID: String
    public let desired: [PreferenceEntry]
    public let label: String

    public init(moduleID: String, desired: [PreferenceEntry], label: String) {
        self.moduleID = moduleID
        self.desired = desired
        self.label = label
    }
}

public struct ApplyResult: Equatable, Sendable {
    public let backupID: UUID
    public let verified: Bool
    public let events: [EngineEvent]
}

/// Central lifecycle: READ → BACKUP → APPLY → VERIFY → HISTORY → RESTORE / RESET → COMPATIBILITY → ERROR.
public final class SettingsEngine: @unchecked Sendable {
    public let backend: PreferenceBackend
    public let history: HistoryStore
    public let compatibility: CompatibilityChecking
    private let lock = NSLock()
    private var events: [EngineEvent] = []
    /// Last known values we wrote — used to detect external changes.
    private var lastKnown: [PreferenceKey: PreferenceValue] = [:]

    public init(
        backend: PreferenceBackend,
        history: HistoryStore,
        compatibility: CompatibilityChecking = CompatibilityChecker()
    ) {
        self.backend = backend
        self.history = history
        self.compatibility = compatibility
    }

    public func recentEvents(limit: Int = 50) -> [EngineEvent] {
        lock.lock(); defer { lock.unlock() }
        return Array(events.suffix(limit))
    }

    @discardableResult
    private func emit(_ phase: EnginePhase, _ message: String, moduleID: String? = nil) -> EngineEvent {
        let event = EngineEvent(phase: phase, message: message, moduleID: moduleID)
        lock.lock(); events.append(event); lock.unlock()
        return event
    }

    // MARK: READ

    public func read(_ keys: [PreferenceKey]) throws -> [PreferenceEntry] {
        emit(.read, "Reading \(keys.count) preference key(s)")
        return try keys.map { try backend.read($0) }
    }

    // MARK: BACKUP

    public func backup(keys: [PreferenceKey], label: String, reason: SnapshotReason, moduleID: String? = nil) throws -> PreferenceSnapshot {
        emit(.backup, "Backing up \(keys.count) key(s): \(label)", moduleID: moduleID)
        let entries = try read(keys)
        let snapshot = PreferenceSnapshot(label: label, reason: reason, entries: entries)
        try history.save(snapshot)
        try history.recordOriginalIfNeeded(snapshot)
        return snapshot
    }

    // MARK: APPLY + VERIFY

    public func apply(_ plan: ApplyPlan, requireCompatibility: CompatibilityReport? = nil) throws -> ApplyResult {
        if let report = requireCompatibility, !report.allowed {
            emit(.error, "Blocked by compatibility: \(report.notes.joined(separator: "; "))", moduleID: plan.moduleID)
            throw SettingsEngineError.incompatible(report.notes.joined(separator: "; "))
        }

        let keys = plan.desired.map(\.key)
        let backupSnap = try backup(
            keys: keys,
            label: "pre-apply: \(plan.label)",
            reason: .preApplyBackup,
            moduleID: plan.moduleID
        )

        emit(.apply, "Applying \(plan.desired.count) change(s) for \(plan.label)", moduleID: plan.moduleID)
        for entry in plan.desired {
            if case .null = entry.value {
                try backend.remove(entry.key)
            } else {
                try backend.write(entry.key, value: entry.value)
            }
            try backend.synchronize(entry.key.domain)
            lock.lock(); lastKnown[entry.key] = entry.value; lock.unlock()
        }

        let verified = try verify(plan.desired)
        if !verified {
            emit(.error, "Verification failed after apply", moduleID: plan.moduleID)
            throw SettingsEngineError.verificationFailed(
                expected: plan.desired.first?.value ?? .null,
                actual: try? backend.read(plan.desired.first!.key).value
            )
        }
        emit(.verify, "Verified apply for \(plan.label)", moduleID: plan.moduleID)
        return ApplyResult(backupID: backupSnap.id, verified: true, events: recentEvents())
    }

    public func verify(_ expected: [PreferenceEntry]) throws -> Bool {
        emit(.verify, "Verifying \(expected.count) preference(s)")
        for entry in expected {
            let actual = try backend.read(entry.key)
            if case .null = entry.value {
                if actual.existed { return false }
            } else if actual.value != entry.value {
                // Float tolerance for corner radii
                if let e = entry.value.doubleValue, let a = actual.value.doubleValue, abs(e - a) < 0.001 {
                    continue
                }
                return false
            }
        }
        return true
    }

    // MARK: HISTORY / RESTORE / RESET

    public func historyList() throws -> [PreferenceSnapshot] {
        emit(.history, "Listing history")
        return try history.all()
    }

    /// Restore Previous — last pre-apply / restore-point snapshot covering the keys.
    public func restorePrevious(keys: [PreferenceKey], moduleID: String? = nil) throws {
        emit(.restore, "Restore Previous", moduleID: moduleID)
        guard let snap = try history.latest(for: keys) else {
            throw SettingsEngineError.noHistory
        }
        try restore(snapshot: snap, moduleID: moduleID)
    }

    /// Restore Original — first captured values before any Tweaksmith write for these keys.
    public func restoreOriginal(keys: [PreferenceKey], moduleID: String? = nil) throws {
        emit(.restore, "Restore Original", moduleID: moduleID)
        guard let snap = try history.original(for: keys) else {
            throw SettingsEngineError.noHistory
        }
        try restore(snapshot: snap, moduleID: moduleID)
    }

    /// Reset to macOS Default — delete keys so the system default applies.
    public func resetToMacOSDefault(keys: [PreferenceKey], moduleID: String? = nil) throws {
        emit(.reset, "Reset to macOS Default", moduleID: moduleID)
        _ = try backup(keys: keys, label: "pre-reset-default", reason: .preApplyBackup, moduleID: moduleID)
        for key in keys {
            try backend.remove(key)
            try backend.synchronize(key.domain)
            lock.lock(); lastKnown[key] = .null; lock.unlock()
        }
    }

    /// Restore All — restore original snapshots for every known history key group, else reset.
    public func restoreAll(moduleID: String? = nil) throws {
        emit(.restore, "Restore All", moduleID: moduleID)
        let snaps = try history.all().filter { $0.reason == .originalCapture || $0.reason == .preApplyBackup }
        // Prefer distinct original files via history.original; fall back to chronological undo of latest backups.
        var seen = Set<PreferenceKey>()
        for snap in snaps {
            let keys = snap.entries.map(\.key).filter { !seen.contains($0) }
            guard !keys.isEmpty else { continue }
            if let original = try history.original(for: keys) {
                try restore(snapshot: original, moduleID: moduleID)
                keys.forEach { seen.insert($0) }
            }
        }
    }

    public func restore(snapshot: PreferenceSnapshot, moduleID: String? = nil) throws {
        emit(.restore, "Restoring snapshot \(snapshot.id)", moduleID: moduleID)
        for entry in snapshot.entries {
            if entry.existed {
                try backend.write(entry.key, value: entry.value)
            } else {
                try backend.remove(entry.key)
            }
            try backend.synchronize(entry.key.domain)
            lock.lock(); lastKnown[entry.key] = entry.existed ? entry.value : .null; lock.unlock()
        }
    }

    // MARK: External change detection

    public struct ExternalChange: Equatable, Sendable {
        public let key: PreferenceKey
        public let expected: PreferenceValue
        public let actual: PreferenceValue
    }

    public func detectExternalChanges(keys: [PreferenceKey]) throws -> [ExternalChange] {
        lock.lock(); let known = lastKnown; lock.unlock()
        var changes: [ExternalChange] = []
        for key in keys {
            guard let expected = known[key] else { continue }
            let actual = try backend.read(key)
            let actualValue = actual.existed ? actual.value : PreferenceValue.null
            if !valuesEqual(expected, actualValue) {
                changes.append(ExternalChange(key: key, expected: expected, actual: actualValue))
            }
        }
        if !changes.isEmpty {
            emit(.error, "Detected \(changes.count) external preference change(s)")
        }
        return changes
    }

    public func adoptCurrentAsKnown(_ keys: [PreferenceKey]) throws {
        for key in keys {
            let entry = try backend.read(key)
            lock.lock()
            lastKnown[key] = entry.existed ? entry.value : .null
            lock.unlock()
        }
    }

    private func valuesEqual(_ a: PreferenceValue, _ b: PreferenceValue) -> Bool {
        if a == b { return true }
        if let da = a.doubleValue, let db = b.doubleValue { return abs(da - db) < 0.001 }
        return false
    }
}
