import FulhamKit
import SwiftUI

// MARK: - CustomRoomSheetPresenter

@Observable
@MainActor
final class CustomRoomSheetPresenter {
	// MARK: - Properties

	private let interactor: any CustomRoomSheetInteractor
	private let router: any CustomRoomSheetRouter
	private let room: Room?
	private let onRoomSaved: ((Room) -> Void)?

	var roomName: String = ""

	var isEditing: Bool {
		room != nil
	}

	var isNameValid: Bool {
		!roomName.trimmingCharacters(in: .whitespaces).isEmpty
	}

	// MARK: - Init

	init(
		interactor: any CustomRoomSheetInteractor,
		router: any CustomRoomSheetRouter,
		room: Room?,
		onRoomSaved: ((Room) -> Void)?
	) {
		self.interactor = interactor
		self.router = router
		self.room = room
		self.onRoomSaved = onRoomSaved
		self.roomName = room?.name ?? ""
	}

	// MARK: - Actions

	func onCancelButtonPressed() {
		router.dismissScreen()
	}

	func onNextButtonPressed() {
		guard isNameValid else { return }
		let trimmedName = roomName.trimmingCharacters(in: .whitespaces)

		if var room {
			room.name = trimmedName

			do {
				try interactor.updateRoom(room)
				onRoomSaved?(room)
				FKHaptics.notification(.success)
				router.dismissScreen()
			} catch {
				return
			}
		} else {
			router.showIconPicker(roomName: trimmedName, room: nil, onRoomSaved: nil)
		}
	}
}
