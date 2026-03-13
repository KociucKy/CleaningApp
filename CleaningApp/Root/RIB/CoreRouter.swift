import NavigationKit
import SwiftUI

// MARK: - CoreRouter

@MainActor
struct CoreRouter {
	// MARK: - Properties

	let router: Router
	let builder: CoreBuilder

	// MARK: - Navigation

	func dismissScreen() {
		router.dismissScreen()
	}

	func popToRoot() {
		router.popToRoot()
	}

	func dismissToRoot() {
		router.dismissToRoot()
	}

	func dismissModal() {
		router.dismissModal()
	}

	func dismissAlert() {
		router.dismissAlert()
	}

	// MARK: - Dev Settings

	func presentDevSettings() {
		router.showScreen(.sheet, onDismiss: nil) { router in
			builder.devSettingsView(router: router)
		}
	}

	func presentReviewKitDebugView() {
		router.showScreen(.push, onDismiss: nil) { _ in
			builder.reviewKitDebugView()
		}
	}
}
