import Foundation
import Testing
@testable import CleaningApp

// MARK: - MockCompletedTaskRepositoryTests

@Suite(.tags(.persistence))
@MainActor
struct MockCompletedTaskRepositoryTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsSeededItems() throws {
		let repo = MockCompletedTaskRepository()
		let result = try repo.fetchAll()
		#expect(result.count == CompletedTaskEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyAfterRemovingAll() throws {
		let repo = MockCompletedTaskRepository()
		repo.items = []
		let result = try repo.fetchAll()
		#expect(result.isEmpty)
	}

	// MARK: - fetchAll(for:)

	@Test func fetchAllForTask_returnsItemsMatchingTaskId() throws {
		let repo = MockCompletedTaskRepository()
		let result = try repo.fetchAllForTaskId(RoomTaskEntity.mockId)
		// Both seeded entries reference RoomTaskEntity.mockId
		#expect(result.count == 2)
		#expect(result.allSatisfy { $0.taskId == RoomTaskEntity.mockId })
	}

	@Test func fetchAllForTask_returnsEmptyForUnknownTaskId() throws {
		let repo = MockCompletedTaskRepository()
		let result = try repo.fetchAllForTaskId(UUID())
		#expect(result.isEmpty)
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_insertsNewEntity() throws {
		let repo = MockCompletedTaskRepository()
		let newEntry = CompletedTaskEntity(
			id: UUID(),
			taskId: RoomTaskEntity.mockId,
			completedAt: .mock,
			measuredDuration: 20
		)
		try repo.save(newEntry)
		let all = try repo.fetchAll()
		#expect(all.contains { $0.id == newEntry.id })
	}

	@Test(.tags(.adding)) func save_upsertsExistingEntity() throws {
		let repo = MockCompletedTaskRepository()
		let existing = CompletedTaskEntity.mock
		existing.measuredDuration = 99
		try repo.save(existing)
		let all = try repo.fetchAll()
		let found = all.first { $0.id == existing.id }
		#expect(found?.measuredDuration == 99)
	}

	@Test(.tags(.adding)) func save_doesNotDuplicateExistingEntity() throws {
		let repo = MockCompletedTaskRepository()
		let countBefore = repo.items.count
		let existing = CompletedTaskEntity.mock
		try repo.save(existing)
		#expect(repo.items.count == countBefore)
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesMatchingEntity() throws {
		let repo = MockCompletedTaskRepository()
		let target = CompletedTaskEntity.mock
		try repo.delete(target)
		let all = try repo.fetchAll()
		#expect(!all.contains { $0.id == target.id })
	}

	@Test(.tags(.deleting)) func delete_doesNotAffectOtherEntities() throws {
		let repo = MockCompletedTaskRepository()
		let countBefore = repo.items.count
		let target = CompletedTaskEntity.mock
		try repo.delete(target)
		#expect(repo.items.count == countBefore - 1)
	}

	@Test(.tags(.deleting)) func delete_noOpForNonExistentEntity() throws {
		let repo = MockCompletedTaskRepository()
		let countBefore = repo.items.count
		let ghost = CompletedTaskEntity(id: UUID(), taskId: UUID(), completedAt: .mock)
		try repo.delete(ghost)
		#expect(repo.items.count == countBefore)
	}
}
