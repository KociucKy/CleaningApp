import Foundation

// MARK: - OnbTaskSelectionPresenter

@Observable
@MainActor
final class OnbTaskSelectionPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	var selectedRooms: [RoomType] {
		interactor.selectedRooms
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
		router.showOnboardingNotificationView()
	}

	func onSkipButtonPressed() {
		router.showOnboardingNotificationView()
	}

	// MARK: - Methods

	func suggestedTasks(for room: RoomType) -> [RoomTask] {
		interactor.suggestedTasks(for: room)
	}

	func isTaskSelected(_ task: RoomTask, for room: RoomType) -> Bool {
		interactor.isTaskSelected(task, for: room)
	}

	func onTaskRowPressed(_ task: RoomTask, for room: RoomType) {
		interactor.toggleTask(task, for: room)
	}
}
