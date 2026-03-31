import Foundation
import NavigationKit

// MARK: - OnboardingRouter

@MainActor
struct OnboardingRouter {
	// MARK: - Properties

	let router: Router
	let builder: OnboardingBuilder

	// MARK: - Navigation

	func showOnboardingRoomSelectionView() {
		router.showScreen(.push, onDismiss: nil) { router in
			builder.roomSelectionView(router: router)
		}
	}

	func showOnboardingTaskSelectionView() {
		router.showScreen(.push, onDismiss: nil) { router in
			builder.taskSelectionView(router: router)
		}
	}

	func showOnboardingNotificationView() {
		router.showScreen(.push, onDismiss: nil) { router in
			builder.notificationView(router: router)
		}
	}

	func showOnboardingPaywallView() {
		router.showScreen(.push, onDismiss: nil) { router in
			builder.paywallView(router: router)
		}
	}

	func showOnboardingCompletedView() {
		router.showScreen(.push, onDismiss: nil) { router in
			builder.onboardingCompletedView(router: router)
		}
	}
}
