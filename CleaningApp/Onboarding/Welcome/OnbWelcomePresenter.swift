import SwiftUI

@Observable
@MainActor
final class OnbWelcomePresenter {
	// MARK: - Properties

	var heroVisible = false
	var titleVisible = false
	var featuresVisible = false
	var buttonVisible = false
	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	// MARK: - Init

	init(interactor: OnboardingInteractor, router: OnboardingRouter) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Actions

	func animateEntrance() {
		withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
			heroVisible = true
		}
		withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
			titleVisible = true
		}
		withAnimation(.easeOut(duration: 0.4).delay(0.55)) {
			featuresVisible = true
		}
		withAnimation(.easeOut(duration: 0.35).delay(0.75)) {
			buttonVisible = true
		}
	}

	func onGetStartedPressed() {
		router.showOnboardingRoomSelectionView()
	}
}
