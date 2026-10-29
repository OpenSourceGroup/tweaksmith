import SwiftUI
import TweaksmithCore

struct AppearanceView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Appearance")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(TSTheme.navy)

                GroupBox {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Window Corners").font(.title2.weight(.semibold))
                        Text("Adjusts undocumented preference NSConvolutionOverride1 (float). Illustrative preview only — not a live window chrome render.")
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Picker("Preset", selection: $model.windowCornersPreset) {
                            ForEach(WindowCornersModule.Preset.allCases) { preset in
                                Text(preset.title).tag(preset)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: model.windowCornersPreset) { _, newValue in
                            if let r = newValue.radius { model.windowCornersRadius = r }
                        }

                        if model.windowCornersPreset == .custom {
                            HStack {
                                Text("Radius")
                                Slider(value: $model.windowCornersRadius, in: 0...20, step: 0.5)
                                Text(String(format: "%.1f", model.windowCornersRadius))
                                    .monospacedDigit()
                                    .frame(width: 44, alignment: .trailing)
                            }
                        }

                        CornerPreview(radius: displayRadius)
                            .frame(height: 140)

                        Label(
                            "May require quitting apps or logging out for full effect. Always reversible.",
                            systemImage: "exclamationmark.triangle"
                        )
                        .foregroundStyle(TSTheme.signal)
                        .font(.callout)

                        Text(WindowCornersModule.override2ValidationNote())
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            Button("Apply") { model.applyWindowCorners() }
                                .buttonStyle(.borderedProminent)
                                .tint(TSTheme.navy)
                            Button("Restore Previous") { model.restorePrevious() }
                            Button("Restore Original") { model.restoreOriginal() }
                            Button("Reset to macOS Default") { model.resetDefault() }
                            Button("Check External Changes") { model.checkExternalChanges() }
                        }

                        if let status = model.statusMessage {
                            Text(status).font(.callout)
                        }
                    }
                    .padding(8)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private var displayRadius: Double {
        model.windowCornersPreset.radius ?? (model.windowCornersPreset == .systemDefault ? 10 : model.windowCornersRadius)
    }
}

struct CornerPreview: View {
    let radius: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(TSTheme.navy.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(TSTheme.paper.opacity(0.5), lineWidth: 1)
                )
            VStack {
                Text("Illustrative preview")
                    .font(.headline)
                    .foregroundStyle(TSTheme.paper)
                Text(String(format: "r = %.1f", radius))
                    .font(.caption.monospaced())
                    .foregroundStyle(TSTheme.paper.opacity(0.85))
            }
        }
        .padding(.vertical, 4)
        .accessibilityLabel("Illustrative window corner preview")
    }
}
