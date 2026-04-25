import SwiftUI

// MARK: - OnbCustomRoomSheetPresenter

@Observable
@MainActor
final class OnbCustomRoomSheetPresenter {
	// MARK: - Properties

	private let onRoomCreated: (String, String) -> Void

	var roomName: String = ""
	var selectedIcon: String?
	var showIconPicker = false

	var isNameValid: Bool {
		!roomName.trimmingCharacters(in: .whitespaces).isEmpty
	}

	// MARK: - Init

	init(onRoomCreated: @escaping (String, String) -> Void) {
		self.onRoomCreated = onRoomCreated
	}

	// MARK: - Actions

	func onNextButtonPressed() {
		guard isNameValid else { return }
		showIconPicker = true
	}

	func onIconSelected(_ icon: String) {
		let trimmedName = roomName.trimmingCharacters(in: .whitespaces)
		onRoomCreated(trimmedName, icon)
	}

	func limitNameLength() {
		if roomName.count > 30 {
			roomName = String(roomName.prefix(30))
		}
	}
}
