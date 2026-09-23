import Foundation

@MainActor
protocol ActivityLogInteractor {
	func fetchAllRoomTasks(for roomId: UUID) throws -> [RoomTask]
	func fetchAllCompletedTasks(forRoomId roomId: UUID) throws -> [CompletedTask]
	func deleteCompletedTask(_ item: CompletedTask) throws
}

extension CoreInteractor: ActivityLogInteractor {}
