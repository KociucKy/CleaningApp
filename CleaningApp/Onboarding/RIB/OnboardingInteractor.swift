import Foundation

// MARK: - OnboardingInteractor

@MainActor
struct OnboardingInteractor {

    // MARK: - Properties

    private let appState: OnboardingState

    // MARK: - Init

    init(container: DependencyContainer) {
        self.appState = container.resolve(OnboardingState.self)!
    }

    // MARK: - App State

    func completeOnboarding() {
        appState.updateViewState(showOnboarding: false)
    }
}