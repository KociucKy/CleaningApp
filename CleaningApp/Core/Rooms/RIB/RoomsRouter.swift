import SwiftUI
import NavigationKit

// MARK: - RoomsRouter

@MainActor
protocol RoomsRouter {
	func dismissScreen()
	func presentRoomsDetailsView(room: Room)
	func presentAddCustomRoomSheet(onDismiss: (() -> Void)?)
	func presentCustomRoomSheet(room: Room, onRoomSaved: @escaping (Room) -> Void)
	func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@MainActor @Sendable () -> AnyView)?)
	func dismissAlert()
}

extension CoreRouter: RoomsRouter {}
