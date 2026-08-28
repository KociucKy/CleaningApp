import Foundation

@Observable
@MainActor
final class RoomsDetailsTaskCompletionPresenter {
	// MARK: - Properties

	private let interactor: any RoomsDetailsTaskCompletionInteractor
	private let router: any RoomsDetailsTaskCompletionRouter
	var completedAt: Date = .now
	var selectedPresetOffset: TimeInterval = 0

	// MARK: - Init

	init(
		interactor: any RoomsDetailsTaskCompletionInteractor,
		router: any RoomsDetailsTaskCompletionRouter
	) {
		self.interactor = interactor
		self.router = router
	}

	// Actions

	func onCloseButtonTapped() {
		router.dismissScreen()
	}

	func onMarkAsCompletedButtonTapped(taskId: UUID) {
		let completedTask = CompletedTask(
			taskId: taskId,
			completedAt: completedAt
		)
		do {
			try interactor.saveCompletedTask(completedTask)
		} catch {
			print("Error")
		}
		router.dismissScreen()
	}
}
