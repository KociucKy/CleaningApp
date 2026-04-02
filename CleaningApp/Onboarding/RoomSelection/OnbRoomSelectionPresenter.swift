import Foundation

// MARK: - OnbRoomSelectionPresenter

@Observable
@MainActor
final class OnbRoomSelectionPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	var selectedRooms: [RoomIcon] {
		interactor.selectedRooms
	}

	var hasSelection: Bool {
		!interactor.selectedRooms.isEmpty
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

	func onNextButtonPressed() {
		router.showOnboardingTaskSelectionView()
	}

	func onSkipButtonPressed() {
		router.showOnboardingNotificationView()
	}

	func onClearButtonPressed() {
		interactor.clearRooms()
	}

	func onRoomCardViewPressed(room: RoomIcon) {
		interactor.toggleRoom(room)
	}

	func isRoomSelected(_ room: RoomIcon) -> Bool {
		interactor.isRoomSelected(room)
	}
}
