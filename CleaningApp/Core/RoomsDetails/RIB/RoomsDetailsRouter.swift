import Foundation
import NavigationKit
import SwiftUI

@MainActor
protocol RoomsDetailsRouter {
	func dismissScreen()
	func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@MainActor @Sendable () -> AnyView)?)
	func dismissAlert()
	func presentRoomsDetailsTaskCompletionSheet(props: RoomsDetailsTaskCompletionProps)
	func presentCustomRoomSheet(
		room: Room,
		onRoomSaved: @escaping (Room) -> Void
	)
	func presentCustomTaskSheet(
		roomId: UUID,
		task: RoomTask?,
		onTaskSaved: @escaping (RoomTask) -> Void
	)
}

extension CoreRouter: RoomsDetailsRouter {}
