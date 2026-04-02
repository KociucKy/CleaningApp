import SwiftUI

// MARK: - OnbRoomSelectionPresenter

@Observable
@MainActor
final class OnbRoomSelectionPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	var visibleCellCount = 0
	private var entranceAnimationIndex = 0

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

	func animateEntrance() {
		let count = RoomType.allCases.count
		Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] timer in
			guard let self else {
				timer.invalidate()
				return
			}
			withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
				visibleCellCount = entranceAnimationIndex + 1
			}
			entranceAnimationIndex += 1
			if entranceAnimationIndex >= count {
				timer.invalidate()
			}
		}
	}

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
