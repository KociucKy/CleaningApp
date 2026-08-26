import Foundation
import NavigationKit

// MARK: - RoomsRouter

@MainActor
protocol RoomsRouter {
	func dismissScreen()
	func presentAddCustomRoomSheet(onDismiss: (() -> Void)?)
}

extension CoreRouter: RoomsRouter {
	func presentAddCustomRoomSheet(onDismiss: (() -> Void)?) {
		router.showScreen(
			.sheetWithDetents([.medium]),
			onDismiss: onDismiss
		) { router in
			builder.customRoomSheetView(router: router)
		}
	}
}
