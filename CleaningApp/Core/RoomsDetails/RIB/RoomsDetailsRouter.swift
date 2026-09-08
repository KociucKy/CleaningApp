import Foundation
import NavigationKit

@MainActor
protocol RoomsDetailsRouter {
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
