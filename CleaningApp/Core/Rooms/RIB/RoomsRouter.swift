import Foundation
import NavigationKit

// MARK: - RoomsRouter

@MainActor
protocol RoomsRouter {
	func dismissScreen()
	func presentRoomsDetailsView(room: Room)
	func presentAddCustomRoomSheet(onDismiss: (() -> Void)?)
	func presentCustomRoomSheet(room: Room, onRoomSaved: @escaping (Room) -> Void)
}

extension CoreRouter: RoomsRouter {}
