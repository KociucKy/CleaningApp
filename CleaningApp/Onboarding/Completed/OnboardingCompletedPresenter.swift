import Foundation

// MARK: - OnboardingCompletedPresenter

@Observable
@MainActor
final class OnboardingCompletedPresenter {

    // MARK: - Properties

    private let interactor: OnboardingInteractor
    private let router: OnboardingRouter

    // MARK: - Init

    init(interactor: OnboardingInteractor, router: OnboardingRouter) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - Actions

    func onFinishButtonPressed() {
        interactor.completeOnboarding()
    }
}