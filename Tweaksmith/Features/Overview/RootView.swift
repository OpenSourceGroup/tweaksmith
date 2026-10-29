import SwiftUI
import TweaksmithCore

struct RootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 760, minHeight: 500)
        .onAppear { model.ensureValidSelection() }
        .sheet(isPresented: $model.supportSheetPresented) {
            SupportPromptSheet()
                .environmentObject(model)
        }
    }

    private var sidebar: some View {
        List(selection: Binding(
            get: { Optional(model.section) },
            set: { newValue in
                model.section = newValue ?? .tweaks
            }
        )) {
            Section(AppModel.Section.tweaks.group) {
                sidebarRow(.tweaks)
            }
            Section(AppModel.Section.activity.group) {
                sidebarRow(.activity)
            }
            Section(AppModel.Section.support.group) {
                sidebarRow(.support)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Tweaksmith")
    }

    private func sidebarRow(_ section: AppModel.Section) -> some View {
        // Explicit Text+Image — Label-only rows laid out at 0×0 on some macOS 26 SPM builds.
        HStack(spacing: 8) {
            Image(systemName: section.systemImage)
                .frame(width: 18, alignment: .center)
                .foregroundStyle(.secondary)
            Text(section.title)
                .font(.body)
            Spacer(minLength: 0)
        }
        .tag(section)
        .accessibilityLabel(section.title)
    }

    @ViewBuilder
    private var detail: some View {
        switch model.section {
        case .tweaks:
            WindowCornersView()
        case .activity:
            ChangesView()
        case .support:
            SupportTweaksmithView()
        }
    }
}
