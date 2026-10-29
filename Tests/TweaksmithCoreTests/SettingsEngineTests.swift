import XCTest
@testable import TweaksmithCore

final class SettingsEngineTests: XCTestCase {
    private var tempDir: URL!
    private var backend: InMemoryPreferenceBackend!
    private var history: FileHistoryStore!
    private var engine: SettingsEngine!
    private var suiteDomain: PreferenceDomain!
    private var key: PreferenceKey!

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ts-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        backend = InMemoryPreferenceBackend()
        history = try FileHistoryStore(directory: tempDir)
        engine = SettingsEngine(
            backend: backend,
            history: history,
            compatibility: CompatibilityChecker(host: HostEnvironment(macOSMajor: 26, macOSMinor: 0, appleSilicon: true))
        )
        suiteDomain = .suite("co.in.kamyab.tweaksmith.tests.\(UUID().uuidString)")
        key = PreferenceKey(domain: suiteDomain, name: WindowCornersModule.override1KeyName)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testReadBackupApplyVerifyLifecycle() throws {
        let module = WindowCornersModule(domain: suiteDomain)
        let plan = module.plan(preset: .sharp4)
        let result = try engine.apply(plan)
        XCTAssertTrue(result.verified)
        let read = try engine.read([key])
        XCTAssertEqual(read.first?.value.doubleValue, 4)
    }

    func testRestorePreviousAndOriginal() throws {
        let module = WindowCornersModule(domain: suiteDomain)
        // Seed an "original" value
        try backend.write(key, value: .double(6))
        _ = try engine.apply(module.plan(preset: .classic10))
        XCTAssertEqual(try backend.read(key).value.doubleValue, 10)

        try engine.restorePrevious(keys: [key])
        // Previous backup before classic10 was 6
        XCTAssertEqual(try backend.read(key).value.doubleValue, 6)

        _ = try engine.apply(module.plan(preset: .subtle8))
        try engine.restoreOriginal(keys: [key])
        XCTAssertEqual(try backend.read(key).value.doubleValue, 6)
    }

    func testResetToMacOSDefaultRemovesKey() throws {
        let module = WindowCornersModule(domain: suiteDomain)
        _ = try engine.apply(module.plan(preset: .sharp4))
        try engine.resetToMacOSDefault(keys: [key])
        let entry = try backend.read(key)
        XCTAssertFalse(entry.existed)
    }

    func testExternalChangeDetection() throws {
        let module = WindowCornersModule(domain: suiteDomain)
        _ = try engine.apply(module.plan(preset: .subtle8))
        // External actor changes preference
        try backend.write(key, value: .double(2))
        let changes = try engine.detectExternalChanges(keys: [key])
        XCTAssertEqual(changes.count, 1)
        XCTAssertEqual(changes.first?.expected.doubleValue, 8)
        XCTAssertEqual(changes.first?.actual.doubleValue, 2)
    }

    func testForbidGlobalDomainInSafeBackend() throws {
        let safe = UserDefaultsPreferenceBackend(forbidGlobalDomain: true)
        let globalKey = PreferenceKey(domain: .global, name: "NSConvolutionOverride1")
        XCTAssertThrowsError(try safe.write(globalKey, value: .double(4)))
    }

    func testModuleRegistration() {
        let registry = ModuleRegistry.production(domain: suiteDomain)
        XCTAssertNotNil(registry.module(id: "window-corners"))
        XCTAssertEqual(registry.modules(in: "Appearance").count, 1)
        XCTAssertTrue(ModuleRegistry.plannedCatalog().contains { $0.status == .planned })
    }

    func testCompatibilityBlocksOldMajorWhenRequired() throws {
        let checker = CompatibilityChecker(host: HostEnvironment(macOSMajor: 14, macOSMinor: 0, appleSilicon: true))
        let report = checker.evaluate(moduleID: "window-corners", minimumMajor: 26, risk: .medium, notes: [])
        XCTAssertFalse(report.allowed)
        let module = WindowCornersModule(domain: suiteDomain)
        XCTAssertThrowsError(try engine.apply(module.plan(preset: .sharp4), requireCompatibility: report))
    }
}
