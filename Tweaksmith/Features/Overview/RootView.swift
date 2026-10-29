import SwiftUI
import TweaksmithCore

struct RootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            List(AppModel.Section.allCases, selection: Binding(
                get: { model.section },
                set: { model.section = $0 }
            )) { section in
                Label(section.rawValue, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
            .listStyle(.sidebar)
        } detail: {
            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(24)
                .background(TSTheme.paper.opacity(0.35))
        }
        .sheet(isPresented: $model.supportSheetPresented) {
            SupportPromptSheet()
                .environmentObject(model)
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch model.section {
        case .overview: OverviewView()
        case .appearance: AppearanceView()
        case .finder: PlannedCategoryView(title: "Finder", category: "Finder")
        case .dockDesktop: PlannedCategoryView(title: "Dock & Desktop", category: "Dock & Desktop")
        case .screenshots: PlannedCategoryView(title: "Screenshots", category: "Screenshots")
        case .productivity: PlannedCategoryView(title: "Productivity", category: "Productivity")
        case .developer: PlannedCategoryView(title: "Developer", category: "Developer")
        case .advanced: PlannedCategoryView(title: "Advanced", category: "Advanced")
        case .support: SupportTweaksmithView()
        case .about: AboutView()
        }
    }
}

struct OverviewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tweaksmith")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(TSTheme.navy)
            Text("Make your Mac yours.")
                .font(.title3)
                .foregroundStyle(TSTheme.graphite)
            Text("Free, open-source, native macOS. Modular and reversible. No telemetry, no ads, no accounts, no locked features.")
                .foregroundStyle(TSTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            GroupBox("Available now") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Window Corners").font(.headline)
                        Text("Appearance · reversible · illustrative preview only")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Open") { model.section = .appearance }
                        .buttonStyle(.borderedProminent)
                        .tint(TSTheme.navy)
                }
                .padding(4)
            }

            if let status = model.statusMessage {
                Text(status)
                    .font(.callout)
                    .foregroundStyle(TSTheme.signal)
            }
            Spacer()
        }
    }
}

struct PlannedCategoryView: View {
    let title: String
    let category: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.largeTitle.weight(.semibold)).foregroundStyle(TSTheme.navy)
            Text("Planned modules — not fake controls.")
                .foregroundStyle(TSTheme.graphite)
            let items = ModuleRegistry.plannedCatalog().filter { $0.category == category && $0.status == .planned }
            if items.isEmpty {
                Text("Nothing planned in this category yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.id) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Text("Planned")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(TSTheme.navy.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(.vertical, 4)
                }
            }
            Spacer()
        }
    }
}
