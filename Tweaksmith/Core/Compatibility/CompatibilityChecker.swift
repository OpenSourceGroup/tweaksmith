import Foundation

public enum CompatibilityRisk: String, Codable, Sendable {
    case low
    case medium
    case high
    case unverified
}

public struct CompatibilityReport: Equatable, Sendable, Codable {
    public let moduleID: String
    public let risk: CompatibilityRisk
    public let macOSMajor: Int
    public let appleSilicon: Bool
    public let notes: [String]
    public let allowed: Bool

    public init(
        moduleID: String,
        risk: CompatibilityRisk,
        macOSMajor: Int,
        appleSilicon: Bool,
        notes: [String],
        allowed: Bool
    ) {
        self.moduleID = moduleID
        self.risk = risk
        self.macOSMajor = macOSMajor
        self.appleSilicon = appleSilicon
        self.notes = notes
        self.allowed = allowed
    }
}

public struct HostEnvironment: Equatable, Sendable {
    public let macOSMajor: Int
    public let macOSMinor: Int
    public let appleSilicon: Bool

    public static func current() -> HostEnvironment {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        #if arch(arm64)
        let silicon = true
        #else
        let silicon = false
        #endif
        return HostEnvironment(macOSMajor: v.majorVersion, macOSMinor: v.minorVersion, appleSilicon: silicon)
    }

    public init(macOSMajor: Int, macOSMinor: Int, appleSilicon: Bool) {
        self.macOSMajor = macOSMajor
        self.macOSMinor = macOSMinor
        self.appleSilicon = appleSilicon
    }
}

public protocol CompatibilityChecking: Sendable {
    func evaluate(
        moduleID: String,
        minimumMajor: Int,
        minimumMinor: Int,
        risk: CompatibilityRisk,
        notes: [String]
    ) -> CompatibilityReport
}

public struct CompatibilityChecker: CompatibilityChecking, Sendable {
    public let host: HostEnvironment

    public init(host: HostEnvironment = .current()) {
        self.host = host
    }

    public func evaluate(
        moduleID: String,
        minimumMajor: Int,
        minimumMinor: Int = 0,
        risk: CompatibilityRisk,
        notes: [String]
    ) -> CompatibilityReport {
        var outNotes = notes
        let allowed = MacOSVersionGate.isAllowed(
            host: host,
            minimumMajor: minimumMajor,
            minimumMinor: minimumMinor
        )
        if !allowed {
            let required = MacOSVersionGate.requirementLabel(minimumMajor: minimumMajor, minimumMinor: minimumMinor)
            let hostLabel = MacOSVersionReporting.fullDescription(host: host)
            outNotes.append("Requires \(required); this Mac reports \(hostLabel). Apply is blocked.")
        }
        if !host.appleSilicon {
            outNotes.append("Apple Silicon is the primary target; Intel is best-effort only.")
        }
        if risk == .high || risk == .unverified {
            outNotes.append("Elevated compatibility risk — review docs/COMPATIBILITY.md before applying.")
        }
        return CompatibilityReport(
            moduleID: moduleID,
            risk: risk,
            macOSMajor: host.macOSMajor,
            appleSilicon: host.appleSilicon,
            notes: outNotes,
            allowed: allowed
        )
    }
}
