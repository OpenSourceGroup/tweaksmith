import SwiftUI
import TweaksmithCore

struct SupportTweaksmithView: View {
    @EnvironmentObject private var model: AppModel
    @State private var customAmount: String = ""

    private let amounts: [(label: String, inr: Int, recommended: Bool)] = [
        ("₹199", 199, false),
        ("₹499", 499, true),
        ("₹999", 999, false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Support")
                    .font(.largeTitle.weight(.semibold))
                Text("Pay what it’s worth.")
                    .font(.title2.weight(.medium))
                Text("Tweaksmith is free and open source. Voluntary support never unlocks features. No accounts, ads, or telemetry. Payments are processed by Kamyab Infotech Pvt Ltd in your browser — the app never handles card data.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Suggested amounts")
                    .font(.headline)

                HStack(spacing: 10) {
                    ForEach(amounts, id: \.inr) { item in
                        Button {
                            model.openSupportInBrowser(amountINR: item.inr)
                        } label: {
                            VStack(spacing: 4) {
                                Text(item.label)
                                    .font(.title3.weight(.semibold))
                                if item.recommended {
                                    Text("Recommended")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(TSTheme.copper)
                                } else {
                                    Text(" ")
                                        .font(.caption2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                        .tint(item.recommended ? TSTheme.copper : nil)
                    }
                }

                HStack {
                    Text("Custom ₹")
                    TextField("Amount", text: $customAmount)
                        .frame(width: 100)
                    Button("Support Tweaksmith") {
                        let parsed = Int(customAmount.trimmingCharacters(in: .whitespacesAndNewlines))
                        model.openSupportInBrowser(amountINR: parsed)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(TSTheme.copper)
                }

                Button("Open support page") {
                    model.openSupportInBrowser()
                }
                .buttonStyle(.link)
            }
            .padding(24)
            .frame(maxWidth: 640, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct SupportPromptSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pay what it’s worth.")
                .font(.title2.weight(.semibold))
            Text("If Tweaksmith helped, you can become a supporter. Nothing is locked either way.")
                .foregroundStyle(.secondary)
            HStack {
                Button("Support Tweaksmith") {
                    model.openSupportInBrowser()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(TSTheme.copper)
                Button("Maybe later") {
                    model.support.markMaybeLater()
                    dismiss()
                }
                Button("Don't ask again") {
                    model.support.markDontAskAgain()
                    dismiss()
                }
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}

struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Group {
                    if let icon = NSApp.applicationIconImage {
                        Image(nsImage: icon)
                            .resizable()
                            .interpolation(.high)
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        ForgedCornerGlyph()
                            .frame(width: 72, height: 72)
                    }
                }
                .accessibilityLabel("Tweaksmith icon")

                Text("Tweaksmith")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
                Text("Make your Mac yours.")
                    .font(.title3)
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                Text("Version \(version) · Developer Preview")
                    .font(.callout)
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                Text("An Open Source Group project.\nMaintained by Kamyab Infotech.")
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .foregroundStyle(Color(nsColor: .labelColor))

                VStack(alignment: .leading, spacing: 6) {
                    Link("Open Source Group", destination: ProjectLinks.osg)
                    Link("GitHub", destination: ProjectLinks.github)
                    Link("Tweaksmith website", destination: ProjectLinks.website)
                    Link("Kamyab Infotech", destination: ProjectLinks.kamyab)
                    Link("MIT License", destination: ProjectLinks.license)
                }
                .font(.callout)
                .padding(.top, 4)

                Text("No telemetry. Offline-capable. Optional payments via Kamyab Infotech Pvt Ltd.")
                    .font(.caption)
                    .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(minWidth: 400, minHeight: 360)
    }
}

/// Inline forged-corner mark used when AppIcon is unavailable.
struct ForgedCornerGlyph: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TSTheme.graphiteDeep)
            // Simplified window with one distinctive corner
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 3, bottomLeading: 3, bottomTrailing: 3, topTrailing: 14)
            )
            .fill(TSTheme.paper.opacity(0.92))
            .frame(width: 34, height: 26)
            .offset(y: 2)
            // Restrained copper spark at the forged corner
            Circle()
                .fill(TSTheme.copper)
                .frame(width: 5, height: 5)
                .offset(x: 12, y: -8)
        }
    }
}
