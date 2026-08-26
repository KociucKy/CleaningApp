import Foundation

@Observable
@MainActor
final class RoomsDetailsPresenter {
	// MARK: - Properties

	private let interactor: any RoomsDetailsInteractor
	private let router: any RoomsDetailsRouter

	// MARK: - Init

	init(
		interactor: any RoomsDetailsInteractor,
		router: any RoomsDetailsRouter
	) {
		self.interactor = interactor
		self.router = router
	}
}
