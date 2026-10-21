import Foundation

@MainActor
protocol ScheduleInteractor {
	func fetchAllRooms() throws -> [Room]
	func fetchAllRoomTasks() throws -> [RoomTask]
	func fetchAllScheduledTasks() throws -> [ScheduledTask]
	func completeScheduledTask(id: UUID, completedAt: Date, measuredDuration: Int?) throws
}

extension CoreInteractor: ScheduleInteractor {}
