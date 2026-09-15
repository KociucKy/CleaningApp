import SwiftUI

// MARK: - IconPickerPresenter

@Observable
@MainActor
final class IconPickerPresenter {
	// MARK: - Properties

	private let interactor: any CustomRoomSheetInteractor
	private let router: any CustomRoomSheetRouter
	private let roomName: String
	private let room: Room?
	private let onRoomSaved: ((Room) -> Void)?

	let icons = IconPickerOptions.icons

	var selectedIcon: String

	// MARK: - Init

	init(
		interactor: any CustomRoomSheetInteractor,
		router: any CustomRoomSheetRouter,
		roomName: String,
		room: Room?,
		onRoomSaved: ((Room) -> Void)?
	) {
		self.interactor = interactor
		self.router = router
		self.roomName = roomName
		self.room = room
		self.onRoomSaved = onRoomSaved
		self.selectedIcon = room?.customIcon ?? room?.kind.symbolName ?? "house.fill"
	}

	// MARK: - Actions

	func onIconSelected(_ icon: String) {
		selectedIcon = icon
	}

	func onDoneButtonPressed() {
		do {
			if var room {
				room.name = roomName
				room.customIcon = selectedIcon
				try interactor.updateRoom(room)
				onRoomSaved?(room)
				router.dismissScreen()
			} else {
				try interactor.saveCustomRoom(name: roomName, icon: selectedIcon)
				router.dismissToRoot()
			}
		} catch {
			// TODO: Surface a save error in the room flow.
		}
	}
}
