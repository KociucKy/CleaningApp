import SwiftUI
import NavigationKit

// MARK: - SettingsView

struct SettingsView: View {

    // MARK: - Properties

    @State var presenter: SettingsPresenter

    // MARK: - Body

    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

// MARK: - Preview

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.settingsView(router: router)
    }
}