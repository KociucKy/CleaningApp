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

	let icons: [String] = [
		"fork.knife",
		"sofa",
		"bed.double",
		"shower",
		"door.left.hand.open",
		"desktopcomputer",
		"car",
		"washer",
		"toilet",
		"fork.knife.circle",
		"house.fill",
		"bed.double.fill",
		"dumbbell",
		"book.fill",
		"paintpalette.fill",
		"leaf.fill",
		"wrench.and.screwdriver.fill",
		"music.note",
		"gamecontroller.fill",
		"laptopcomputer",
		"tv.fill",
		"car.fill",
		"cart.fill",
		"tent.fill",
		"pawprint.fill",
		"figure.walk",
		"tshirt.fill",
		"cup.and.saucer.fill",
		"square.grid.2x2",
	]

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
