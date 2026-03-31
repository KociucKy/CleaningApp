import Foundation

@Observable
@MainActor
final class OnbRoomSelectionPresenter {
	// MARK: - Properties

	var selectedRooms: Set<RoomIcon> = []
	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

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
		router.showOnboardingCompletedView()
	}

	func onClearButtonPressed() {
		selectedRooms = []
	}

	func onRoomCardViewPressed(room: RoomIcon) {
		if selectedRooms.contains(room) {
			selectedRooms.remove(room)
		} else {
			selectedRooms.insert(room)
		}
	}
}
