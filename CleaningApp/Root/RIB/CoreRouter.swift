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

	func presentAddCustomRoomSheet(onDismiss: (() -> Void)?) {
		router.showScreen(
			.sheetWithDetents([.medium]),
			onDismiss: onDismiss
		) { router in
			builder.customRoomSheetView(router: router)
		}
	}

	func presentRoomsDetailsView(room: Room) {
		router.showScreen(.push, onDismiss: nil) { router in
			builder.roomsDetailsView(router: router, room: room)
		}
	}

	func presentRoomsDetailsTaskCompletionSheet(taskName: String) {
		router.showScreen(.sheetWithDetents([.medium]), onDismiss: nil) { router in
			builder.roomsDetailsTaskCompletionView(router: router, taskName: taskName)
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
