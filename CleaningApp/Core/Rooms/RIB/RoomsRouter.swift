import Foundation
import NavigationKit

// MARK: - RoomsRouter

@MainActor
protocol RoomsRouter {
	func dismissScreen()
	func presentRoomsDetailsView(room: Room)
	func presentAddCustomRoomSheet(onDismiss: (() -> Void)?)
}

extension CoreRouter: RoomsRouter {}
