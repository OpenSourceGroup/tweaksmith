import Foundation

#if canImport(Darwin)
import Darwin
#endif

/// Reads macOS marketing version (major/minor/patch) separately from the Darwin build string (`kern.osversion`).
public enum MacOSVersionReporting: Sendable {
    /// Darwin build identifier, e.g. `26B123` — not the same as the marketing `26.x` version.
    public static func buildVersionString() -> String? {
        #if canImport(Darwin)
        var size = 0
        guard sysctlbyname("kern.osversion", nil, &size, nil, 0) == 0, size > 1 else { return nil }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname("kern.osversion", &buffer, &size, nil, 0) == 0 else { return nil }
        let raw = String(cString: buffer)
        return raw.isEmpty ? nil : raw
        #else
        return nil
        #endif
    }

    public static func marketingVersionString(from host: HostEnvironment) -> String {
        "\(host.macOSMajor).\(host.macOSMinor)"
    }

    /// Human-readable label for support / About: `macOS 26.4 (build 26B123)`.
    public static func fullDescription(host: HostEnvironment = .current()) -> String {
        let marketing = marketingVersionString(from: host)
        if let build = buildVersionString() {
            return "macOS \(marketing) (build \(build))"
        }
        return "macOS \(marketing)"
    }
}

public enum MacOSVersionGate: Sendable {
    /// True when `host` meets or exceeds `minimumMajor.minimumMinor` (patch ignored).
    public static func isAllowed(host: HostEnvironment, minimumMajor: Int, minimumMinor: Int) -> Bool {
        if host.macOSMajor > minimumMajor { return true }
        if host.macOSMajor < minimumMajor { return false }
        return host.macOSMinor >= minimumMinor
    }

    public static func requirementLabel(minimumMajor: Int, minimumMinor: Int) -> String {
        if minimumMinor > 0 {
            return "macOS \(minimumMajor).\(minimumMinor)+"
        }
        return "macOS \(minimumMajor)+"
    }
}
