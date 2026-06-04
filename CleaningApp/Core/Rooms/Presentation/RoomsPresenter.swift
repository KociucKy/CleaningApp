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
	var isLoading: Bool = true

	// MARK: - Init

	init(interactor: any RoomsInteractor, router: any RoomsRouter) {
		self.interactor = interactor
		self.router = router

		do {
			let fetchedRooms = try interactor.fetchRooms()
			rooms = fetchedRooms.sorted { $0.createdAt > $1.createdAt }
			isLoading = false
		} catch {
			errorMessage = "Failed to load rooms"
			isLoading = false
		}
	}
}
