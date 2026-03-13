import SwiftUI
import NavigationKit

// MARK: - SettingsInteractor

@MainActor
protocol SettingsInteractor {
    // TODO: Define Settings interactor methods
}

extension CoreInteractor: SettingsInteractor {}

// MARK: - SettingsRouter

@MainActor
protocol SettingsRouter {
    func dismissScreen()
}

extension CoreRouter: SettingsRouter {}

// MARK: - SettingsPresenter

@Observable
@MainActor
final class SettingsPresenter {

    // MARK: - Properties

    private let interactor: any SettingsInteractor
    private let router: any SettingsRouter

    // MARK: - Init

    init(interactor: any SettingsInteractor, router: any SettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
}

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