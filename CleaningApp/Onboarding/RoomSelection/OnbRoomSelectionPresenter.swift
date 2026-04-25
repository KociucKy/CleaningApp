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
	var buttonVisible = false

	var selectedRooms: [RoomType] {
		interactor.selectedRooms
	}

	var hasSelection: Bool {
		!interactor.selectedRooms.isEmpty || !interactor.customRooms.isEmpty
	}

	var customRooms: [CustomRoomSelection] {
		interactor.customRooms
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
		let predefinedCount = RoomType.allCases.count(where: { $0 != .customRoom })
		let totalCount = predefinedCount + interactor.customRooms.count
		Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] timer in
			guard let self else {
				timer.invalidate()
				return
			}
			withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
				visibleCellCount = entranceAnimationIndex + 1
			}
			entranceAnimationIndex += 1
			if entranceAnimationIndex >= totalCount {
				timer.invalidate()
				withAnimation(.easeOut(duration: 0.35)) {
					buttonVisible = true
				}
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

	func onCustomRoomCreated(name: String, icon: String) {
		interactor.addCustomRoom(name: name, icon: icon)
	}

	func onCustomRoomCardPressed(id: UUID) {
		interactor.toggleCustomRoom(id: id)
	}

	func isCustomRoomSelected(_ id: UUID) -> Bool {
		interactor.isCustomRoomSelected(id: id)
	}
}
