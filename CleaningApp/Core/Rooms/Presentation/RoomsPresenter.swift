import SwiftUI
import FulhamKit

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
	var toast: FKToast?
	var isReordering: Bool = false

	// MARK: - Init

	init(interactor: any RoomsInteractor, router: any RoomsRouter) {
		self.interactor = interactor
		self.router = router
		self.fetchRooms()
	}

	// MARK: - Methods

	func fetchRooms() {
		do {
			let fetchedRooms = try interactor.fetchRooms()
			rooms = fetchedRooms.sorted { $0.createdAt > $1.createdAt }
			isLoading = false
		} catch {
			errorMessage = "Failed to load rooms"
			isLoading = false
		}
	}

	// MARK: - Actions

	func onAddButtonTapped() {
		router.presentAddCustomRoomSheet { [weak self] in
			self?.onCustomRoomSheetDismissed()
		}
	}

	// MARK: - Private

	private func onCustomRoomSheetDismissed() {
		let previousCount = rooms.count
		fetchRooms()
		if rooms.count > previousCount {
			toast = FKToast(
				message: String(localized: "rooms.custom_room_added_toast"),
				style: .success,
				duration: 3.0
			)
		}
	}
}
