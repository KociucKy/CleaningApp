import Foundation

// MARK: - OnbRoomSelectionPresenter

@Observable
@MainActor
final class OnbRoomSelectionPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	var selectedRooms: [RoomType] {
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

	func onRoomCardViewPressed(room: RoomType) {
		interactor.toggleRoom(room)
	}

	func isRoomSelected(_ room: RoomType) -> Bool {
		interactor.isRoomSelected(room)
	}
}
