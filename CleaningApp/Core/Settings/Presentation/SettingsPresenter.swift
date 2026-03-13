import Foundation

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