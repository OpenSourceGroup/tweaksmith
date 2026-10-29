import SwiftUI

/// Precision-workshop tokens: graphite, warm paper, copper accent. Prefer semantic colors for text/chrome.
enum TSTheme {
    /// Warm copper accent — use sparingly (Apply confirmation, key affordances).
    static let copper = Color(red: 196 / 255, green: 110 / 255, blue: 52 / 255)
    /// Near-black graphite for forged-corner surfaces.
    static let graphiteDeep = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
    /// Warm off-white paper.
    static let paper = Color(red: 245 / 255, green: 242 / 255, blue: 235 / 255)
    /// Legacy aliases kept for gradual migration.
    static let navy = Color(red: 42 / 255, green: 61 / 255, blue: 111 / 255)
    static let signal = copper
    static let ink = Color.primary
    static let graphite = Color.secondary
}
