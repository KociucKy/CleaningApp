import SwiftUI
import FulhamKit

@Observable
@MainActor
final class RoomsDetailsTaskCompletionPresenter {
	// MARK: - Properties

	private let interactor: any RoomsDetailsTaskCompletionInteractor
	private let router: any RoomsDetailsTaskCompletionRouter
	var completedAt: Date = .now
	var selectedPresetOffset: TimeInterval = 0
	var hasAppeared = false
	var animateSymbol = false

	// MARK: - Init

	init(
		interactor: any RoomsDetailsTaskCompletionInteractor,
		router: any RoomsDetailsTaskCompletionRouter
	) {
		self.interactor = interactor
		self.router = router
	}

	// Actions

	func onAppear(animationDelay: Double) {
		hasAppeared = true
		DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) { [weak self] in
			guard let self else { return }
			self.animateSymbol = true
		}
	}

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

	func onPresetSelected(offset: TimeInterval) {
		withTransaction(Transaction(animation: nil)) {
			selectedPresetOffset = offset
			completedAt = Date().addingTimeInterval(offset)
		}
		DispatchQueue.main.async {
			FKHaptics.impact(.light)
		}
	}
}
