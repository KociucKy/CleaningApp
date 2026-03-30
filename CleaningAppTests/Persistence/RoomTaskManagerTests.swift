import Foundation
import Testing
@testable import CleaningApp

// MARK: - RoomTaskManagerTests

@Suite(.tags(.persistence))
@MainActor
struct RoomTaskManagerTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsMappedDomainModels() throws {
		let manager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
		let tasks = try manager.fetchAll()
		#expect(tasks.count == RoomTaskEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyWhenRepositoryIsEmpty() throws {
		let taskRepo = MockRoomTaskRepository()
		taskRepo.items = []
		let manager = RoomTaskManager(
			taskRepository: taskRepo,
			roomRepository: MockRoomRepository()
		)
		#expect(try manager.fetchAll().isEmpty)
	}

	@Test func fetchAll_mapsIdAndNameCorrectly() throws {
		let manager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
		let tasks = try manager.fetchAll()
		let ids = tasks.map(\.id)
		let entityIds = RoomTaskEntity.mocks.map(\.id)
		#expect(Set(ids) == Set(entityIds))
	}

	// MARK: - fetchAll(for:)

	@Test func fetchAllForRoom_returnsTasksForMatchingRoom() throws {
		let manager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
		let tasks = try manager.fetchAll(for: Room.mockId)
		#expect(tasks.count == RoomTaskEntity.mocks.count)
		#expect(tasks.allSatisfy { $0.roomId == Room.mockId })
	}

	@Test func fetchAllForRoom_returnsEmptyForUnknownRoom() throws {
		let manager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
		let tasks = try manager.fetchAll(for: UUID())
		#expect(tasks.isEmpty)
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_persistsNewTask() throws {
		let taskRepo = MockRoomTaskRepository()
		taskRepo.items = []
		let manager = RoomTaskManager(
			taskRepository: taskRepo,
			roomRepository: MockRoomRepository()
		)
		let newTask = RoomTask(
			id: UUID(),
			name: "Mop floor",
			roomId: Room.mockId,
			frequency: .weekly,
			estimatedDuration: .thirtyMinutes,
			createdAt: .mock
		)
		try manager.save(newTask)
		let all = try manager.fetchAll()
		#expect(all.contains { $0.id == newTask.id })
	}

	@Test(.tags(.adding)) func save_silentlyIgnoresTaskWithUnknownRoomId() throws {
		let taskRepo = MockRoomTaskRepository()
		taskRepo.items = []
		let manager = RoomTaskManager(
			taskRepository: taskRepo,
			roomRepository: MockRoomRepository()
		)
		let orphanTask = RoomTask(
			id: UUID(),
			name: "Orphan",
			roomId: UUID(), // room doesn't exist in mock repo
			frequency: .daily,
			estimatedDuration: .fifteenMinutes,
			createdAt: .mock
		)
		try manager.save(orphanTask)
		#expect(try manager.fetchAll().isEmpty)
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesTask() throws {
		let manager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
		let task = RoomTask.mock
		let countBefore = try manager.fetchAll().count
		try manager.delete(task)
		let countAfter = try manager.fetchAll().count
		#expect(countAfter == countBefore - 1)
	}

	@Test(.tags(.deleting)) func delete_silentlyIgnoresTaskWithUnknownRoomId() throws {
		let manager = RoomTaskManager(
			taskRepository: MockRoomTaskRepository(),
			roomRepository: MockRoomRepository()
		)
		let countBefore = try manager.fetchAll().count
		let orphan = RoomTask(
			id: UUID(),
			name: "Orphan",
			roomId: UUID(),
			frequency: .daily,
			estimatedDuration: .fifteenMinutes,
			createdAt: .mock
		)
		try manager.delete(orphan)
		#expect(try manager.fetchAll().count == countBefore)
	}
}
