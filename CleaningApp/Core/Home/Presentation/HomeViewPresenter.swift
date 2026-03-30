import Foundation

// MARK: - HomePresenter

@Observable
@MainActor
final class HomeViewPresenter {
	// MARK: - Properties

	private(set) var rooms: [Room] = []
	private let interactor: any HomeInteractor
	private let router: any HomeRouter

	// MARK: - Init

	init(interactor: any HomeInteractor, router: any HomeRouter) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Dev Settings

	func showDevSettings() {
		router.presentDevSettings()
	}

	// MARK: - Rooms

	func fetchAllRooms() {
		do {
			rooms = try interactor.fetchAllRooms()
		} catch {
			
		}
	}
}
