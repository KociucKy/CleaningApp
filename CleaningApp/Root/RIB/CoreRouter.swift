import NavigationKit
import SwiftUI

// MARK: - CoreRouter

@MainActor
struct CoreRouter {
	// MARK: - Properties

	let router: Router
	let builder: CoreBuilder

	// MARK: - Core Navigation

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

	func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?){
		router.showAlert(
			option,
			title: title,
			subtitle: subtitle,
			buttons: buttons
		)
	}

	func showAlert(error: Error) {
		router.showAlert(
			.alert,
			title: "Error",
			subtitle: error.localizedDescription,
			buttons: nil
		)
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
			builder.customRoomSheetView(router: router, room: nil, onRoomSaved: nil)
		}
	}

	func presentCustomRoomSheet(
		room: Room,
		onRoomSaved: @escaping (Room) -> Void
	) {
		router.showScreen(
			.sheetWithDetents([.medium]),
			onDismiss: nil
		) { router in
			builder.customRoomSheetView(
				router: router,
				room: room,
				onRoomSaved: onRoomSaved
			)
		}
	}

	func presentRoomsDetailsView(room: Room) {
		router.showScreen(.push, onDismiss: nil) { router in
			builder.roomsDetailsView(router: router, room: room)
		}
	}

	func presentRoomsDetailsTaskCompletionSheet(props: RoomsDetailsTaskCompletionProps) {
		router.showScreen(.sheetWithDetents([.fraction(0.7)]), onDismiss: nil) { router in
			builder.roomsDetailsTaskCompletionView(router: router, props: props)
		}
	}

	func presentCustomTaskSheet(
		roomId: UUID,
		task: RoomTask?,
		onTaskSaved: @escaping (RoomTask) -> Void
	) {
		router.showScreen(.sheetWithDetents([.medium]), onDismiss: nil) { router in
			builder.customTaskSheetView(
				router: router,
				roomId: roomId,
				task: task,
				onTaskSaved: onTaskSaved
			)
		}
	}

	func showIconPicker(
		roomName: String,
		room: Room?,
		onRoomSaved: ((Room) -> Void)?
	) {
		let sheetRouter = self
		router.showScreen(.push, onDismiss: nil) { _ in
			builder.iconPickerView(
					sheetRouter: sheetRouter,
					roomName: roomName,
					room: room,
					onRoomSaved: onRoomSaved
				)
		}
	}
}
