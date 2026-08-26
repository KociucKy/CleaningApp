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

	func presentUserDefaultsDebugView() {
		router.showScreen(.push, onDismiss: nil) { _ in
			builder.userDefaultsDebugView()
		}
	}

	func presentLocalNotificationDebugView() {
		router.showScreen(.push, onDismiss: nil) { _ in
			builder.localNotificationsDebugView()
		}
	}

	func presentDeviceDebugView() {
		router.showScreen(.push, onDismiss: nil) { _ in
			builder.deviceDebugView()
		}
	}

	// MARK: - Rooms

	func presentAddCustomRoomView() {
		router.showScreen(.sheetWithDetents([.medium]), onDismiss: nil) { router in

		}
	}
}

// MARK: - CustomRoomSheetRouter (Rooms Context)

extension CoreRouter: CustomRoomSheetRouter {
	func showIconPicker(roomName: String) {
		let sheetRouter = self
		router.showScreen(.push, onDismiss: nil) { _ in
			builder.iconPickerView(sheetRouter: sheetRouter, roomName: roomName)
		}
	}
}
