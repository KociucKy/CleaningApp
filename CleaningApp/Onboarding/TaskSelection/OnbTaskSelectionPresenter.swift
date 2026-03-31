import Foundation

@Observable
@MainActor
final class OnbTaskSelectionPresenter {
	// MARK: - Properties

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

	func onNextButtonPressed() {
		router.showOnboardingNotificationView()
	}
}
