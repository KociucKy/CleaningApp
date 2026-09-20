import SwiftUI

// MARK: - Tab Bar Selection

extension EnvironmentValues {
    @Entry var tabBarSelection: String?
}

// MARK: - TabBarScreen

struct TabBarScreen: Identifiable {
    // MARK: - Properties

    var id: String {
        title
    }

    let title: String
    let systemImage: String
    let role: TabRole?
    @ViewBuilder var screen: () -> AnyView

    // MARK: - Init

    init(
        title: String,
        systemImage: String,
        role: TabRole? = nil,
        screen: @escaping () -> AnyView
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.screen = screen
    }
}

// MARK: - TabBarView

struct TabBarView: View {
    // MARK: - Properties

    var tabs: [TabBarScreen]
    @State private var selectedTabID: String?

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTabID) {
            ForEach(tabs) { tab in
                if let role = tab.role {
                    Tab(value: tab.id, role: role) {
                        tabView(tab)
                    }
                } else {
                    Tab(tab.title, systemImage: tab.systemImage, value: tab.id) {
                        tab.screen()
                    }
                }
            }
        }
        .environment(\.tabBarSelection, selectedTabID)
    }

    // MARK: - Views

    private func tabView(_ tab: TabBarScreen) -> some View {
        tab.screen()
            .tabItem {
                Label(tab.title, systemImage: tab.systemImage)
            }
    }
}
