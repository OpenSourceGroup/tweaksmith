import XCTest
@testable import TweaksmithCore

final class CompatibilityCheckerTests: XCTestCase {
    private let moduleID = "window-corners"
    private let minMajor = 26
    private let minMinor = 4

    func testVersionGate26_3Blocked() {
        XCTAssertFalse(MacOSVersionGate.isAllowed(
            host: HostEnvironment(macOSMajor: 26, macOSMinor: 3, appleSilicon: true),
            minimumMajor: minMajor,
            minimumMinor: minMinor
        ))
        let report = checker(host: 26, minor: 3).evaluate(
            moduleID: moduleID,
            minimumMajor: minMajor,
            minimumMinor: minMinor,
            risk: .medium,
            notes: []
        )
        XCTAssertFalse(report.allowed)
        XCTAssertTrue(report.notes.joined().contains("26.4"))
    }

    func testVersionGate26_4Allowed() {
        XCTAssertTrue(MacOSVersionGate.isAllowed(
            host: HostEnvironment(macOSMajor: 26, macOSMinor: 4, appleSilicon: true),
            minimumMajor: minMajor,
            minimumMinor: minMinor
        ))
        let report = checker(host: 26, minor: 4).evaluate(
            moduleID: moduleID,
            minimumMajor: minMajor,
            minimumMinor: minMinor,
            risk: .medium,
            notes: []
        )
        XCTAssertTrue(report.allowed)
    }

    func testVersionGate27Allowed() {
        XCTAssertTrue(MacOSVersionGate.isAllowed(
            host: HostEnvironment(macOSMajor: 27, macOSMinor: 0, appleSilicon: true),
            minimumMajor: minMajor,
            minimumMinor: minMinor
        ))
        let report = checker(host: 27, minor: 2).evaluate(
            moduleID: moduleID,
            minimumMajor: minMajor,
            minimumMinor: minMinor,
            risk: .medium,
            notes: []
        )
        XCTAssertTrue(report.allowed)
    }

    func testOldMajorBlocked() {
        let report = checker(host: 14, minor: 0).evaluate(
            moduleID: moduleID,
            minimumMajor: minMajor,
            minimumMinor: minMinor,
            risk: .medium,
            notes: []
        )
        XCTAssertFalse(report.allowed)
    }

    func testApplyBlockedWhenCompatibilityFails() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ts-compat-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let backend = InMemoryPreferenceBackend()
        let history = try FileHistoryStore(directory: tempDir)
        let engine = SettingsEngine(backend: backend, history: history, compatibility: checker(host: 26, minor: 3))
        let domain = PreferenceDomain.suite("co.in.kamyab.tweaksmith.tests.\(UUID().uuidString)")
        let module = WindowCornersModule(domain: domain)
        let key = module.preferenceKeys[0]

        let report = checker(host: 26, minor: 3).evaluate(
            moduleID: module.id,
            minimumMajor: module.minimumMacOSMajor,
            minimumMinor: module.minimumMacOSMinor,
            risk: module.compatibilityRisk,
            notes: []
        )
        XCTAssertFalse(report.allowed)

        XCTAssertThrowsError(try engine.apply(module.plan(preset: .sharp4), requireCompatibility: report))
        let entry = try backend.read(key)
        XCTAssertFalse(entry.existed, "Blocked apply must not write preferences")
    }

    func testBackupApplyRestoreRoundTrip() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ts-round-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let backend = InMemoryPreferenceBackend()
        let history = try FileHistoryStore(directory: tempDir)
        let engine = SettingsEngine(backend: backend, history: history, compatibility: checker(host: 26, minor: 4))
        let domain = PreferenceDomain.suite("co.in.kamyab.tweaksmith.tests.\(UUID().uuidString)")
        let module = WindowCornersModule(domain: domain)
        let key = module.preferenceKeys[0]

        try backend.write(key, value: .double(6))
        _ = try engine.backup(keys: [key], label: "seed", reason: .originalCapture)

        let report = checker(host: 26, minor: 4).evaluate(
            moduleID: module.id,
            minimumMajor: module.minimumMacOSMajor,
            minimumMinor: module.minimumMacOSMinor,
            risk: module.compatibilityRisk,
            notes: []
        )
        let result = try engine.apply(module.plan(preset: .subtle8), requireCompatibility: report)
        XCTAssertTrue(result.verified)
        XCTAssertEqual(try backend.read(key).value.doubleValue, 8)

        try engine.restorePrevious(keys: [key])
        XCTAssertEqual(try backend.read(key).value.doubleValue, 6)
    }

    func testMarketingVersionString() {
        let host = HostEnvironment(macOSMajor: 26, macOSMinor: 4, appleSilicon: true)
        XCTAssertEqual(MacOSVersionReporting.marketingVersionString(from: host), "26.4")
    }

    private func checker(host major: Int, minor: Int) -> CompatibilityChecker {
        CompatibilityChecker(host: HostEnvironment(macOSMajor: major, macOSMinor: minor, appleSilicon: true))
    }
}
