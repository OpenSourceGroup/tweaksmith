import SwiftUI
import TweaksmithCore

struct SupportTweaksmithView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support Tweaksmith")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(TSTheme.navy)
            Text("Free software. Pay what it's worth.")
                .font(.title3)
            Text("Voluntary support never unlocks features. There are no accounts, ads, or telemetry. Payments are processed on kamyab.co.in in your browser — the app never handles card data or trusts URL query flags like ?paid=true.")
                .foregroundStyle(TSTheme.graphite)
                .fixedSize(horizontal: false, vertical: true)

            Button("Pay what it's worth") {
                model.openSupportInBrowser()
            }
            .buttonStyle(.borderedProminent)
            .tint(TSTheme.signal)

            Button("Become a Tweaksmith Supporter") {
                model.openSupportInBrowser()
            }
            .buttonStyle(.bordered)

            Spacer()
        }
    }
}

struct SupportPromptSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Free software. Pay what it's worth.")
                .font(.title2.weight(.semibold))
            Text("If Tweaksmith helped, you can become a supporter. Nothing is locked either way.")
                .foregroundStyle(.secondary)
            HStack {
                Button("Pay what it's worth") {
                    model.openSupportInBrowser()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(TSTheme.signal)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About").font(.largeTitle.weight(.semibold)).foregroundStyle(TSTheme.navy)
            Text("Tweaksmith by Kamyab")
                .font(.title3)
            Text("Make your Mac yours.")
            Text("Official site: https://kamyab.co.in/tweaksmith")
                .foregroundStyle(TSTheme.navy)
            Text("© Kamyab Infotech Private Limited. Code licensed MIT. Branding (name, logo, identity) remains Kamyab-controlled.")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("No telemetry. Offline-capable native app. Official builds published by Kamyab via GitHub Releases.")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
