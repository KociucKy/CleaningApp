import Foundation
import NavigationKit

// MARK: - OnboardingRouter

@MainActor
struct OnboardingRouter {

    // MARK: - Properties

    let router: Router
    let builder: OnboardingBuilder

    // MARK: - Navigation

    func showOnboardingCompletedView() {
        router.showScreen(.push, onDismiss: nil) { router in
            builder.onboardingCompletedView(router: router)
        }
    }
}