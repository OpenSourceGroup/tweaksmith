import Foundation

public protocol HistoryStore: Sendable {
    func save(_ snapshot: PreferenceSnapshot) throws
    func load(id: UUID) throws -> PreferenceSnapshot
    func latest(for keys: [PreferenceKey]?) throws -> PreferenceSnapshot?
    func all() throws -> [PreferenceSnapshot]
    func original(for keys: [PreferenceKey]) throws -> PreferenceSnapshot?
    func recordOriginalIfNeeded(_ snapshot: PreferenceSnapshot) throws
    func clear() throws
}

/// File-backed history under Application Support. Tests inject a temp directory.
public final class FileHistoryStore: HistoryStore, @unchecked Sendable {
    private let root: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let lock = NSLock()

    public init(directory: URL) throws {
        self.root = directory
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: originalsDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: snapshotsDir, withIntermediateDirectories: true)
    }

    private var snapshotsDir: URL { root.appendingPathComponent("snapshots", isDirectory: true) }
    private var originalsDir: URL { root.appendingPathComponent("originals", isDirectory: true) }

    public func save(_ snapshot: PreferenceSnapshot) throws {
        lock.lock(); defer { lock.unlock() }
        let url = snapshotsDir.appendingPathComponent("\(snapshot.id.uuidString).json")
        let data = try encoder.encode(snapshot)
        try data.write(to: url, options: .atomic)
    }

    public func load(id: UUID) throws -> PreferenceSnapshot {
        lock.lock(); defer { lock.unlock() }
        let url = snapshotsDir.appendingPathComponent("\(id.uuidString).json")
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw SettingsEngineError.snapshotNotFound(id)
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(PreferenceSnapshot.self, from: data)
    }

    public func latest(for keys: [PreferenceKey]?) throws -> PreferenceSnapshot? {
        let snaps = try all()
        guard let keys, !keys.isEmpty else { return snaps.first }
        let keySet = Set(keys)
        return snaps.first { snap in
            Set(snap.entries.map(\.key)).isSuperset(of: keySet) ||
            snap.entries.contains { keySet.contains($0.key) }
        }
    }

    public func all() throws -> [PreferenceSnapshot] {
        lock.lock(); defer { lock.unlock() }
        let urls = try FileManager.default.contentsOfDirectory(
            at: snapshotsDir,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ).filter { $0.pathExtension == "json" }
        let snaps = try urls.map { try decoder.decode(PreferenceSnapshot.self, from: Data(contentsOf: $0)) }
        return snaps.sorted { $0.createdAt > $1.createdAt }
    }

    public func original(for keys: [PreferenceKey]) throws -> PreferenceSnapshot? {
        lock.lock(); defer { lock.unlock() }
        let name = originalFileName(for: keys)
        let url = originalsDir.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try decoder.decode(PreferenceSnapshot.self, from: Data(contentsOf: url))
    }

    public func recordOriginalIfNeeded(_ snapshot: PreferenceSnapshot) throws {
        lock.lock(); defer { lock.unlock() }
        let name = originalFileName(for: snapshot.entries.map(\.key))
        let url = originalsDir.appendingPathComponent(name)
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        var original = snapshot
        // Re-label as original capture without changing entries.
        original = PreferenceSnapshot(
            id: snapshot.id,
            createdAt: snapshot.createdAt,
            label: snapshot.label,
            reason: .originalCapture,
            entries: snapshot.entries
        )
        let data = try encoder.encode(original)
        try data.write(to: url, options: .atomic)
    }

    public func clear() throws {
        lock.lock(); defer { lock.unlock() }
        let fm = FileManager.default
        for dir in [snapshotsDir, originalsDir] {
            if fm.fileExists(atPath: dir.path) {
                try fm.removeItem(at: dir)
            }
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    private func originalFileName(for keys: [PreferenceKey]) -> String {
        let joined = keys.map { "\($0.domain.identifier).\($0.name)" }.sorted().joined(separator: "|")
        let digest = joined.data(using: .utf8).map { data -> String in
            var hash: UInt64 = 5381
            for b in data { hash = ((hash << 5) &+ hash) &+ UInt64(b) }
            return String(hash, radix: 16)
        } ?? "empty"
        return "original-\(digest).json"
    }
}
