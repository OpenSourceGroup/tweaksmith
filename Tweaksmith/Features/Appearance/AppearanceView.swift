import SwiftUI
import TweaksmithCore

struct WindowCornersView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                stateRow
                if !model.lastExternalChanges.isEmpty {
                    externalBanner
                }
                previewCard
                presetBlock
                applyRow
                restoreBlock
                if let status = model.statusMessage {
                    Text(status)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Window Corners")
                .font(.largeTitle.weight(.semibold))
            Text("Adjust the macOS window-corner preference used by supported apps. Changes are reversible.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var stateRow: some View {
        HStack(spacing: 16) {
            stateChip(title: "Current", value: model.currentRadiusDescription)
            Image(systemName: "arrow.right")
                .foregroundStyle(.tertiary)
            stateChip(title: "Selected", value: model.selectedRadiusDescription)
            Spacer(minLength: 0)
        }
    }

    private func stateChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.medium))
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var externalBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(TSTheme.copper)
            Text("Changed outside Tweaksmith")
                .font(.callout.weight(.medium))
            Spacer(minLength: 0)
            Button("Refresh") { model.refreshFromSystem() }
                .buttonStyle(.bordered)
        }
        .padding(10)
        .background(TSTheme.copper.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview")
                .font(.headline)
            LiveWindowPreview(radius: displayRadius, reduceMotion: reduceMotion)
                .frame(height: 168)
                .accessibilityLabel("Live window corner preview")
                .accessibilityValue(String(format: "Radius %.1f", displayRadius))
        }
    }

    private var presetBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Presets")
                .font(.headline)
            Picker("Preset", selection: $model.windowCornersPreset) {
                ForEach(WindowCornersModule.Preset.allCases) { preset in
                    Text(shortPresetTitle(preset)).tag(preset)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onChange(of: model.windowCornersPreset) { _, newValue in
                if let r = newValue.radius {
                    model.windowCornersRadius = r
                    model.customRadiusField = String(format: "%.1f", r)
                }
            }

            if model.windowCornersPreset == .custom {
                HStack(spacing: 12) {
                    Text("Radius")
                    Slider(
                        value: Binding(
                            get: { model.windowCornersRadius },
                            set: { newValue in
                                model.windowCornersRadius = newValue
                                model.customRadiusField = String(format: "%.1f", newValue)
                            }
                        ),
                        in: WindowCornersModule.minRadius...min(20, WindowCornersModule.maxRadius),
                        step: 0.5
                    )
                    TextField("0–40", text: $model.customRadiusField)
                        .frame(width: 56)
                        .multilineTextAlignment(.trailing)
                        .onSubmit { syncCustomFromField() }
                    Text("pt")
                        .foregroundStyle(.secondary)
                }
                .onChange(of: model.customRadiusField) { _, _ in
                    if let v = Double(model.customRadiusField), let s = WindowCornersModule.sanitiseRadius(v) {
                        model.windowCornersRadius = s
                    }
                }
            }
        }
    }

    private var applyRow: some View {
        HStack(spacing: 12) {
            Button("Apply") { model.applyWindowCorners() }
                .buttonStyle(.borderedProminent)
                .tint(TSTheme.copper)
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("apply-window-corners")
                .help("Apply the selected Window Corners preset")
            if model.applyConfirmationVisible {
                Label("Applied", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(TSTheme.copper)
                    .font(.callout.weight(.medium))
                    .transition(reduceMotion ? .opacity : .move(edge: .leading).combined(with: .opacity))
            }
            Spacer(minLength: 0)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: model.applyConfirmationVisible)
    }

    private var restoreBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Restore & Safety")
                .font(.headline)
            Text("Previous undoes the last apply. Original restores the first value Tweaksmith captured. Reset removes the preference key (macOS default).")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button("Restore Previous") { model.restorePrevious() }
                    .help("Undo the last apply from history.")
                Button("Restore Original") { model.restoreOriginal() }
                    .help("Restore the first value captured before Tweaksmith changed it.")
                Button("Reset to macOS Default") { model.resetDefault() }
                    .help("Delete NSConvolutionOverride1 so macOS uses its default.")
            }
            Button("Check for external changes") { model.checkExternalChanges() }
                .buttonStyle(.link)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var displayRadius: Double {
        if model.windowCornersPreset == .systemDefault { return 10 }
        if model.windowCornersPreset == .custom { return model.windowCornersRadius }
        return model.windowCornersPreset.radius ?? model.windowCornersRadius
    }

    private func shortPresetTitle(_ preset: WindowCornersModule.Preset) -> String {
        switch preset {
        case .systemDefault: return "System"
        case .sharp4: return "Sharp 4"
        case .subtle8: return "Subtle 8"
        case .classic10: return "Classic 10"
        case .custom: return "Custom"
        }
    }

    private func syncCustomFromField() {
        if let v = Double(model.customRadiusField), let s = WindowCornersModule.sanitiseRadius(v) {
            model.windowCornersRadius = s
            model.customRadiusField = String(format: "%.1f", s)
        }
    }
}

/// Stylized live window preview with traffic lights; corner radius animates with presets.
struct LiveWindowPreview: View {
    let radius: Double
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.06))
            windowChrome
                .padding(20)
        }
    }

    private var windowChrome: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Circle().fill(Color(red: 1, green: 0.37, blue: 0.35)).frame(width: 10, height: 10)
                Circle().fill(Color(red: 1, green: 0.74, blue: 0.25)).frame(width: 10, height: 10)
                Circle().fill(Color(red: 0.3, green: 0.78, blue: 0.35)).frame(width: 10, height: 10)
                Spacer(minLength: 0)
                Text("Preview")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.primary.opacity(0.04))

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 3).fill(Color.primary.opacity(0.12)).frame(height: 8)
                RoundedRectangle(cornerRadius: 3).fill(Color.primary.opacity(0.08)).frame(height: 8).padding(.trailing, 40)
                RoundedRectangle(cornerRadius: 3).fill(Color.primary.opacity(0.08)).frame(height: 8).padding(.trailing, 80)
                Spacer(minLength: 0)
                Text(String(format: "r = %.1f", radius))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85), value: radius)
    }
}

/// History of Settings Engine events for Window Corners.
struct ChangesView: View {
    @EnvironmentObject private var model: AppModel

    private static let stamp: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Changes")
                .font(.largeTitle.weight(.semibold))
            Text("History from the Settings Engine for Window Corners.")
                .foregroundStyle(.secondary)

            if model.engineEvents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No changes yet. Apply a Window Corners preset to start history.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                List(Array(model.engineEvents.reversed())) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(Self.stamp.string(from: event.at))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                            Spacer(minLength: 0)
                            Text(event.phase == .error ? "Failed" : "OK")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(event.phase == .error ? .red : TSTheme.copper)
                        }
                        Text(event.phase.rawValue.capitalized)
                            .font(.caption.weight(.medium))
                        Text(event.message)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 2)
                    .accessibilityElement(children: .combine)
                }
                .listStyle(.inset)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { model.engineEvents = model.engine.recentEvents() }
    }
}

// Compatibility alias — older call sites / docs.
typealias AppearanceView = WindowCornersView
