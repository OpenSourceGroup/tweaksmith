import Foundation
import TweaksmithCore

/// Lightweight smoke runner for environments without XCTest (CLT-only hosts).
/// CI with full Xcode should prefer `swift test` once XCTest is available.

@main
enum Smoke {
    static func expect(_ cond: Bool, _ msg: String, failures: inout Int) {
        if cond {
            print("PASS  \(msg)")
        } else {
            failures += 1
            print("FAIL  \(msg)")
        }
    }

    static func main() throws {
        var failures = 0
        try settingsEngine(failures: &failures)
        try supportPrompt(failures: &failures)
        moduleRegistration(failures: &failures)
        print(failures == 0 ? "\nALL SMOKE TESTS PASSED" : "\n\(failures) FAILURE(S)")
        if failures != 0 { exit(1) }
    }

    static func settingsEngine(failures: inout Int) throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("ts-smoke-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }

        let backend = InMemoryPreferenceBackend()
        let history = try FileHistoryStore(directory: temp)
        let engine = SettingsEngine(
            backend: backend,
            history: history,
            compatibility: CompatibilityChecker(host: HostEnvironment(macOSMajor: 26, macOSMinor: 0, appleSilicon: true))
        )
        let domain = PreferenceDomain.suite("co.in.kamyab.tweaksmith.smoke.\(UUID().uuidString)")
        let module = WindowCornersModule(domain: domain)
        let key = module.preferenceKeys[0]

        try backend.write(key, value: .double(6))
        let result = try engine.apply(module.plan(preset: .sharp4))
        expect(result.verified, "apply+verify sharp4", failures: &failures)
        expect(try backend.read(key).value.doubleValue == 4, "value is 4 after apply", failures: &failures)

        try engine.restorePrevious(keys: [key])
        expect(try backend.read(key).value.doubleValue == 6, "restore previous → 6", failures: &failures)

        _ = try engine.apply(module.plan(preset: .subtle8))
        try engine.restoreOriginal(keys: [key])
        expect(try backend.read(key).value.doubleValue == 6, "restore original → 6", failures: &failures)

        _ = try engine.apply(module.plan(preset: .classic10))
        try engine.resetToMacOSDefault(keys: [key])
        expect(try backend.read(key).existed == false, "reset removes key", failures: &failures)

        _ = try engine.apply(module.plan(preset: .subtle8))
        try backend.write(key, value: .double(2))
        let changes = try engine.detectExternalChanges(keys: [key])
        expect(changes.count == 1, "detect external change", failures: &failures)

        let safe = UserDefaultsPreferenceBackend(forbidGlobalDomain: true)
        var threw = false
        do {
            try safe.write(PreferenceKey(domain: .global, name: "NSConvolutionOverride1"), value: .double(4))
        } catch {
            threw = true
        }
        expect(threw, "forbid global domain in CI backend", failures: &failures)

        let oldHost = CompatibilityChecker(host: HostEnvironment(macOSMajor: 14, macOSMinor: 0, appleSilicon: true))
        let report = oldHost.evaluate(moduleID: "window-corners", minimumMajor: 26, risk: .medium, notes: [])
        expect(!report.allowed, "compatibility blocks old major", failures: &failures)
    }

    static func supportPrompt(failures: inout Int) throws {
        let suite = "co.in.kamyab.tweaksmith.smoke.support.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let first = Date(timeIntervalSince1970: 1_700_000_000)
        let nowBox = NowBox(first)
        let controller = SupportPromptController(defaults: defaults, now: { nowBox.value })
        controller.save(SupportPromptState(firstLaunchAt: first))
        for _ in 0..<5 { controller.recordSuccessfulAction() }
        if case .suppress = controller.decision() {
            expect(true, "suppress first launch day", failures: &failures)
        } else {
            expect(false, "suppress first launch day", failures: &failures)
        }

        nowBox.value = first.addingTimeInterval(86_400 * 2)
        controller.save(SupportPromptState(successfulActionCount: 3, firstLaunchAt: first))
        expect(controller.decision() == .show, "show after 3 actions + later day", failures: &failures)

        controller.markDontAskAgain()
        if case .suppress = controller.decision() {
            expect(true, "dont ask again", failures: &failures)
        } else {
            expect(false, "dont ask again", failures: &failures)
        }
        expect(controller.decision(isManualOpen: true) == .show, "manual open always", failures: &failures)
        expect(SupportPromptController.supportURL.host == "kamyab.co.in", "support host kamyab.co.in", failures: &failures)
    }

    static func moduleRegistration(failures: inout Int) {
        let domain = PreferenceDomain.suite("x")
        let registry = ModuleRegistry.production(domain: domain)
        expect(registry.module(id: "window-corners") != nil, "window-corners registered", failures: &failures)
        expect(ModuleRegistry.plannedCatalog().contains { $0.status == .planned }, "planned catalog non-empty", failures: &failures)
        expect(WindowCornersModule.override2ValidationNote().contains("Override2"), "override2 note present", failures: &failures)
        expect(WindowCornersModule.sanitiseRadius(8) == 8, "radius 8 ok", failures: &failures)
        expect(WindowCornersModule.sanitiseRadius(-1) == nil, "radius negative rejected", failures: &failures)
        expect(WindowCornersModule.sanitiseRadius(.nan) == nil, "radius nan rejected", failures: &failures)
        expect(WindowCornersModule.sanitiseRadius(999) == nil, "radius huge rejected", failures: &failures)
        let plan = WindowCornersModule(domain: domain).plan(preset: .custom, customRadius: .infinity)
        expect(plan.desired.first?.value.doubleValue == 8, "invalid custom falls back to 8", failures: &failures)
    }
}

private final class NowBox: @unchecked Sendable {
    var value: Date
    init(_ value: Date) { self.value = value }
}
