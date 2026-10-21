import Foundation

@MainActor
protocol ScheduleInteractor {
	func fetchAllRooms() throws -> [Room]
	func fetchAllRoomTasks() throws -> [RoomTask]
	func fetchAllScheduledTasks() throws -> [ScheduledTask]
}

extension CoreInteractor: ScheduleInteractor {}
