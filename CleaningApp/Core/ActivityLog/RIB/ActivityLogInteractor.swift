import Foundation

@MainActor
protocol ActivityLogInteractor {
	func fetchAllRoomTasks(for roomId: UUID) throws -> [RoomTask]
	func fetchAllCompletedTasks(forRoomId roomId: UUID) throws -> [CompletedTask]
}

extension CoreInteractor: ActivityLogInteractor {}
