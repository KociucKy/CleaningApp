import SwiftUI
import FulhamKit

// MARK: - RoomsPresenter

@Observable
@MainActor
final class RoomsPresenter {
	// MARK: - Properties
	enum State {
		case isLoading
		case loaded
		case error(String)
		case empty
	}

	private let interactor: any RoomsInteractor
	private let router: any RoomsRouter

	private(set) var rooms: [Room] = []
	var state: State = .isLoading
	var toast: FKToast?

	// MARK: - Init

	init(interactor: any RoomsInteractor, router: any RoomsRouter) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Methods

	private func fetchRooms() {
		do {
			let fetchedRooms = try interactor.fetchRooms()
			rooms = fetchedRooms.sorted { $0.createdAt > $1.createdAt }
			if rooms.isEmpty {
				state = .empty
			} else {
				state = .loaded
			}
		} catch {
			let errorMessage = "Failed to load rooms"
			state = .error(errorMessage)
		}
	}

	// MARK: - Actions

	func onAppearFetch() {
		guard case .isLoading = state else {
			return
		}
		fetchRooms()
	}

	func onRoomCardTapped(room: Room) {
		router.presentRoomsDetailsView(room: room)
	}

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
