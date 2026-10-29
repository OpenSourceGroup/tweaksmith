import Foundation

/// Local-only voluntary support prompt. Never gates features. Never phones home.
public struct SupportPromptState: Equatable, Sendable, Codable {
    public var successfulActionCount: Int
    public var unsolicitedPromptCount: Int
    public var lastPromptAt: Date?
    public var dontAskAgain: Bool
    public var dismissedUntil: Date?
    public var firstLaunchAt: Date

    public init(
        successfulActionCount: Int = 0,
        unsolicitedPromptCount: Int = 0,
        lastPromptAt: Date? = nil,
        dontAskAgain: Bool = false,
        dismissedUntil: Date? = nil,
        firstLaunchAt: Date = Date()
    ) {
        self.successfulActionCount = successfulActionCount
        self.unsolicitedPromptCount = unsolicitedPromptCount
        self.lastPromptAt = lastPromptAt
        self.dontAskAgain = dontAskAgain
        self.dismissedUntil = dismissedUntil
        self.firstLaunchAt = firstLaunchAt
    }
}

public enum SupportPromptDecision: Equatable, Sendable {
    case show
    case suppress(reason: String)
}

public final class SupportPromptController: @unchecked Sendable {
    public static let supportURL = URL(string: "https://kamyab.co.in/tweaksmith/support")!
    public static let productURL = URL(string: "https://kamyab.co.in/tweaksmith")!

    public static let minSuccessfulActions = 3
    public static let maxUnsolicited = 3
    public static let waitDays: TimeInterval = 30 * 24 * 60 * 60

    private let defaults: UserDefaults
    private let key: String
    private let now: () -> Date
    private let lock = NSLock()

    public init(
        defaults: UserDefaults,
        key: String = "supportPromptState",
        now: @escaping () -> Date = Date.init
    ) {
        self.defaults = defaults
        self.key = key
        self.now = now
    }

    public func load() -> SupportPromptState {
        lock.lock(); defer { lock.unlock() }
        guard let data = defaults.data(forKey: key),
              let state = try? JSONDecoder().decode(SupportPromptState.self, from: data) else {
            return SupportPromptState(firstLaunchAt: now())
        }
        return state
    }

    public func save(_ state: SupportPromptState) {
        lock.lock(); defer { lock.unlock() }
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: key)
        }
    }

    public func recordSuccessfulAction() {
        var state = load()
        state.successfulActionCount += 1
        save(state)
    }

    public func decision(isManualOpen: Bool = false) -> SupportPromptDecision {
        let state = load()
        if isManualOpen { return .show }
        if state.dontAskAgain { return .suppress(reason: "User chose Don't ask again") }
        // Never on first launch calendar day
        let calendar = Calendar.current
        if calendar.isDate(state.firstLaunchAt, inSameDayAs: now()) {
            return .suppress(reason: "Never on first launch")
        }
        if state.successfulActionCount < Self.minSuccessfulActions {
            return .suppress(reason: "Need ≥\(Self.minSuccessfulActions) successful actions")
        }
        if state.unsolicitedPromptCount >= Self.maxUnsolicited {
            return .suppress(reason: "Reached max \(Self.maxUnsolicited) unsolicited prompts")
        }
        if let until = state.dismissedUntil, now() < until {
            return .suppress(reason: "Inside 30-day wait window")
        }
        if let last = state.lastPromptAt, now().timeIntervalSince(last) < Self.waitDays {
            return .suppress(reason: "Inside 30-day wait window")
        }
        return .show
    }

    public func markPromptShown() {
        var state = load()
        state.unsolicitedPromptCount += 1
        state.lastPromptAt = now()
        state.dismissedUntil = now().addingTimeInterval(Self.waitDays)
        save(state)
    }

    public func markMaybeLater() {
        var state = load()
        state.lastPromptAt = now()
        state.dismissedUntil = now().addingTimeInterval(Self.waitDays)
        save(state)
    }

    public func markDontAskAgain() {
        var state = load()
        state.dontAskAgain = true
        save(state)
    }
}
