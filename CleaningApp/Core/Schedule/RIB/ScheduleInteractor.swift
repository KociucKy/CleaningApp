import Foundation

@MainActor
protocol ScheduleInteractor {
	func fetchAllRooms() throws -> [Room]
	func fetchAllRoomTasks() throws -> [RoomTask]
	func fetchAllScheduledTasks() throws -> [ScheduledTask]
	func completeScheduledTask(id: UUID, completedAt: Date, measuredDuration: Int?) throws
	func skipScheduledTask(id: UUID, skippedAt: Date, dailyLimit: Int) throws -> ScheduleMutation
	func undoSkipScheduledTask(id: UUID, restoredAt: Date) throws
	func refreshSchedule(today: Date, dailyLimit: Int) throws -> ScheduleMutation
	func dailyScheduleLimit() -> Int
}

extension CoreInteractor: ScheduleInteractor {}
