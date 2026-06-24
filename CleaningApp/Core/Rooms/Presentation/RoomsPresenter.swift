import Foundation

// MARK: - RoomsPresenter

@Observable
@MainActor
final class RoomsPresenter {
	// MARK: - Properties

	private let interactor: any RoomsInteractor
	private let router: any RoomsRouter

	var rooms: [Room] = []
	var errorMessage: String?
	var isLoading = true
	var isShowingMenu = false

	// MARK: - Init

	init(interactor: any RoomsInteractor, router: any RoomsRouter) {
		self.interactor = interactor
		self.router = router
		self.fetchRooms()
	}

	// MARK: - Methods

	private func fetchRooms() {
		do {
			let fetchedRooms = try interactor.fetchRooms()
			rooms = fetchedRooms.sorted { $0.createdAt > $1.createdAt }
			isLoading = false
		} catch {
			errorMessage = "Failed to load rooms"
			isLoading = false
		}
	}

	func onAddButtonTapped() {
		
	}
}
