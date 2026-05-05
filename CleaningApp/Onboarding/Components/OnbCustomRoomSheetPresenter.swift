import SwiftUI

// MARK: - OnbCustomRoomSheetPresenter

@Observable
@MainActor
final class OnbCustomRoomSheetPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	var roomName: String = ""

	var isNameValid: Bool {
		!roomName.trimmingCharacters(in: .whitespaces).isEmpty
	}

	// MARK: - Init

	init(
		interactor: OnboardingInteractor,
		router: OnboardingRouter
	) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Actions

	func onCancelButtonPressed() {
		router.dismissScreen()
	}

	func onNextButtonPressed() {
		guard isNameValid else { return }
		let trimmedName = roomName.trimmingCharacters(in: .whitespaces)
		router.showIconPickerView(roomName: trimmedName)
	}

	func limitNameLength() {
		if roomName.count > 30 {
			roomName = String(roomName.prefix(30))
		}
	}
}
