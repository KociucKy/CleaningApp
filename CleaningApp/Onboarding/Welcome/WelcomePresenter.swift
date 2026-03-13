import Foundation

// MARK: - WelcomePresenter

@Observable
@MainActor
final class WelcomePresenter {

    // MARK: - Properties

    private let interactor: OnboardingInteractor
    private let router: OnboardingRouter

    // MARK: - Init

    init(interactor: OnboardingInteractor, router: OnboardingRouter) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - Actions

    func onGetStartedPressed() {
        router.showOnboardingCompletedView()
    }
}