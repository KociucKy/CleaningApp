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

	@available(iOS 27, *)
	func onRoomsReordered(
		_ difference: ReorderDifference<Room.ID, ReorderableSingleCollectionIdentifier>
	) {
		let movingIDs = difference.sources

		let movingRooms = rooms.filter { movingIDs.contains($0.id) }
		rooms.removeAll { movingIDs.contains($0.id) }

		switch difference.destination.position {
		case .before(let destinationID):
			guard let destinationIndex = rooms.firstIndex(
				where: { $0.id == destinationID }
			) else {
				rooms.append(contentsOf: movingRooms)
				return
			}

			rooms.insert(contentsOf: movingRooms, at: destinationIndex)

		case .end:
			rooms.append(contentsOf: movingRooms)
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
