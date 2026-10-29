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
            Text("Voluntary support never unlocks features. There are no accounts, ads, or telemetry. Optional payments are processed by Kamyab Infotech Pvt Ltd, the project's maintainer, in your browser. The app never handles card data or trusts URL query flags like ?paid=true.")
                .foregroundStyle(TSTheme.graphite)
                .fixedSize(horizontal: false, vertical: true)

            Button("Support Tweaksmith") {
                model.openSupportInBrowser()
            }
            .buttonStyle(.borderedProminent)
            .tint(TSTheme.signal)

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
                Button("Support Tweaksmith") {
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
            Text("Make your Mac yours.")
                .font(.title3)
            Text("An Open Source Group project.")
            Text("Maintained by Kamyab Infotech.")
            VStack(alignment: .leading, spacing: 4) {
                Link("Open Source Group", destination: ProjectLinks.osg)
                Link("GitHub", destination: ProjectLinks.github)
                Link("Tweaksmith website", destination: ProjectLinks.website)
                Link("Kamyab Infotech", destination: ProjectLinks.kamyab)
                Link("MIT License", destination: ProjectLinks.license)
            }
            .font(.callout)
            Text("Code licensed MIT. Copyright (c) 2026 Kamyab Infotech Private Limited.")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("No telemetry. Offline-capable native app. Optional payments are processed by Kamyab Infotech Pvt Ltd, the project's maintainer.")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
