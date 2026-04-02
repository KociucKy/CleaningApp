import SwiftUI

// MARK: - OnboardingCompletedPresenter

@Observable
@MainActor
final class OnboardingCompletedPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	var iconVisible = false
	var titleVisible = false
	var statsVisible = false
	var buttonVisible = false
	var isSaving = false

	var roomsCount: Int {
		interactor.selectedRoomsCount
	}

	var tasksCount: Int {
		interactor.selectedTasksCount
	}

	// MARK: - Init

	init(interactor: OnboardingInteractor, router: OnboardingRouter) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Actions

	func animateEntrance() {
		withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
			iconVisible = true
		}
		withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
			titleVisible = true
		}
		withAnimation(.easeOut(duration: 0.4).delay(0.55)) {
			statsVisible = true
		}
		withAnimation(.easeOut(duration: 0.35).delay(0.8)) {
			buttonVisible = true
		}
	}

	func onFinishButtonPressed() {
		guard !isSaving else { return }
		isSaving = true
		interactor.saveAndCompleteOnboarding()
	}
}
