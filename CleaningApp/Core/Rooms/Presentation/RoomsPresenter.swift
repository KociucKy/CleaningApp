import Foundation

// MARK: - RoomsPresenter

@Observable
@MainActor
final class RoomsPresenter {

    // MARK: - Properties

    private let interactor: any RoomsInteractor
    private let router: any RoomsRouter

    // MARK: - Init

    init(interactor: any RoomsInteractor, router: any RoomsRouter) {
        self.interactor = interactor
        self.router = router
    }
}