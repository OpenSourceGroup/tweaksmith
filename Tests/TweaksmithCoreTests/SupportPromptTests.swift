import XCTest
@testable import TweaksmithCore

final class SupportPromptTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        suiteName = "co.in.kamyab.tweaksmith.support.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testNeverOnFirstLaunch() {
        let now = Date()
        let controller = SupportPromptController(defaults: defaults, now: { now })
        for _ in 0..<5 { controller.recordSuccessfulAction() }
        if case .suppress(let reason) = controller.decision() {
            XCTAssertTrue(reason.contains("first launch"))
        } else {
            XCTFail("Should suppress on first launch")
        }
    }

    func testRequiresThreeSuccessfulActions() {
        let first = Date(timeIntervalSince1970: 1_700_000_000)
        let later = first.addingTimeInterval(86_400 * 2)
        var current = later
        let controller = SupportPromptController(defaults: defaults, now: { current })
        // Force firstLaunchAt to past by saving state
        var state = SupportPromptState(firstLaunchAt: first)
        controller.save(state)
        controller.recordSuccessfulAction()
        controller.recordSuccessfulAction()
        if case .suppress = controller.decision() {
            // ok
        } else {
            XCTFail("Need 3 actions")
        }
        controller.recordSuccessfulAction()
        XCTAssertEqual(controller.decision(), .show)
        _ = current
    }

    func testMaxThreeUnsolicitedAndDontAskAgain() {
        let first = Date(timeIntervalSince1970: 1_700_000_000)
        var current = first.addingTimeInterval(86_400 * 40)
        let controller = SupportPromptController(defaults: defaults, now: { current })
        controller.save(SupportPromptState(
            successfulActionCount: 10,
            firstLaunchAt: first
        ))
        for i in 0..<3 {
            XCTAssertEqual(controller.decision(), .show, "prompt \(i)")
            controller.markPromptShown()
            current = current.addingTimeInterval(SupportPromptController.waitDays + 60)
        }
        if case .suppress(let reason) = controller.decision() {
            XCTAssertTrue(reason.contains("max"))
        } else {
            XCTFail("Should stop after 3")
        }

        controller.save(SupportPromptState(successfulActionCount: 10, dontAskAgain: true, firstLaunchAt: first))
        if case .suppress(let reason) = controller.decision() {
            XCTAssertTrue(reason.lowercased().contains("don't ask") || reason.contains("Don't ask"))
        } else {
            XCTFail("dont ask again")
        }
    }

    func testManualOpenAlwaysAllowed() {
        let controller = SupportPromptController(defaults: defaults)
        controller.markDontAskAgain()
        XCTAssertEqual(controller.decision(isManualOpen: true), .show)
    }

    func testSupportURLIsKamyabCoIn() {
        XCTAssertEqual(SupportPromptController.supportURL.host, "kamyab.co.in")
        XCTAssertFalse(SupportPromptController.supportURL.absoluteString.contains("kamyab.in/"))
    }
}
