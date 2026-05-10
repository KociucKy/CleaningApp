import Foundation
import NavigationKit

// MARK: - OnboardingRouter

@MainActor
struct OnboardingRouter {
	// MARK: - Properties

	let router: Router
	let builder: OnboardingBuilder

	// MARK: - Navigation

	func dismissScreen() {
		router.dismissScreen()
	}

	func dismissToRoot() {
		router.dismissToRoot()
	}

	func dismissModal() {
		router.dismissModal()
	}

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

	func presentCustomRoomSheet() {
		router.showScreen(.sheetWithDetents([.medium]), onDismiss: nil) { router in
			builder.customRoomSheetView(router: router)
		}
	}

	func presentCustomTaskSheet(for roomType: RoomType) {
		router.showScreen(.sheetWithDetents([.medium]), onDismiss: nil) { router in
			builder.customTaskSheetView(router: router, roomType: roomType)
		}
	}

	func showIconPickerView(roomName: String) {
		router.showScreen(.push, onDismiss: nil) { _ in
			builder.iconPickerView(sheetRouter: self, roomName: roomName)
		}
	}
}
