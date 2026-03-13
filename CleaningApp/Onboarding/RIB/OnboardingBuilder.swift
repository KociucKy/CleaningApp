import SwiftUI
import NavigationKit

// MARK: - OnboardingBuilder

@MainActor
struct OnboardingBuilder: Builder {

    // MARK: - Properties

    let interactor: OnboardingInteractor

    // MARK: - Builder

    func build() -> AnyView {
        welcomeView().any()
    }

    // MARK: - Views

    func welcomeView() -> some View {
        RouterView { router in
            WelcomeView(
                presenter: WelcomePresenter(
                    interactor: interactor,
                    router: OnboardingRouter(router: router, builder: self)
                )
            )
        }
    }

    func onboardingCompletedView(router: Router) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(
                interactor: interactor,
                router: OnboardingRouter(router: router, builder: self)
            )
        )
    }
}