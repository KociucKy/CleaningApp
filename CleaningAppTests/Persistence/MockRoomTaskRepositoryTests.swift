import Foundation
import Testing
@testable import CleaningApp

// MARK: - MockRoomTaskRepositoryTests

@Suite(.tags(.persistence))
@MainActor
struct MockRoomTaskRepositoryTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsSeededItems() throws {
		let repo = MockRoomTaskRepository()
		let result = try repo.fetchAll()
		#expect(result.count == RoomTaskEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyAfterRemovingAll() throws {
		let repo = MockRoomTaskRepository()
		repo.items = []
		let result = try repo.fetchAll()
		#expect(result.isEmpty)
	}

	// MARK: - fetchAll(for:)

	@Test func fetchAllForRoom_returnsTasksForMatchingRoom() throws {
		let repo = MockRoomTaskRepository()
		let result = try repo.fetchAll(for: RoomEntity.mockId)
		// All seeded tasks belong to RoomEntity.mock
		#expect(result.count == RoomTaskEntity.mocks.count)
		#expect(result.allSatisfy { $0.room?.id == RoomEntity.mockId })
	}

	@Test func fetchAllForRoom_returnsEmptyForUnknownRoomId() throws {
		let repo = MockRoomTaskRepository()
		let result = try repo.fetchAll(for: UUID())
		#expect(result.isEmpty)
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_insertsNewEntity() throws {
		let repo = MockRoomTaskRepository()
		let newTask = RoomTaskEntity(
			id: UUID(),
			name: "New Task",
			room: .mock,
			frequencyEncoded: "daily",
			estimatedDuration: 15,
			createdAt: .mock
		)
		try repo.save(newTask)
		let all = try repo.fetchAll()
		#expect(all.contains { $0.id == newTask.id })
	}

	@Test(.tags(.adding)) func save_upsertsExistingEntity() throws {
		let repo = MockRoomTaskRepository()
		let existing = RoomTaskEntity.mock
		existing.name = "Updated Task"
		try repo.save(existing)
		let all = try repo.fetchAll()
		let found = all.first { $0.id == existing.id }
		#expect(found?.name == "Updated Task")
	}

	@Test(.tags(.adding)) func save_doesNotDuplicateExistingEntity() throws {
		let repo = MockRoomTaskRepository()
		let countBefore = repo.items.count
		let existing = RoomTaskEntity.mock
		try repo.save(existing)
		#expect(repo.items.count == countBefore)
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesMatchingEntity() throws {
		let repo = MockRoomTaskRepository()
		let target = RoomTaskEntity.mock
		try repo.delete(target)
		let all = try repo.fetchAll()
		#expect(!all.contains { $0.id == target.id })
	}

	@Test(.tags(.deleting)) func delete_doesNotAffectOtherEntities() throws {
		let repo = MockRoomTaskRepository()
		let countBefore = repo.items.count
		let target = RoomTaskEntity.mock
		try repo.delete(target)
		#expect(repo.items.count == countBefore - 1)
	}

	@Test(.tags(.deleting)) func delete_noOpForNonExistentEntity() throws {
		let repo = MockRoomTaskRepository()
		let countBefore = repo.items.count
		let ghost = RoomTaskEntity(
			id: UUID(),
			name: "Ghost",
			room: nil,
			frequencyEncoded: "daily",
			estimatedDuration: 15,
			createdAt: .mock
		)
		try repo.delete(ghost)
		#expect(repo.items.count == countBefore)
	}
}
