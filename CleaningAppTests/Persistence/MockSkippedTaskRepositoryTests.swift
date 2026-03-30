import Foundation
import Testing
@testable import CleaningApp

// MARK: - MockSkippedTaskRepositoryTests

@Suite(.tags(.persistence))
@MainActor
struct MockSkippedTaskRepositoryTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsSeededItems() throws {
		let repo = MockSkippedTaskRepository()
		let result = try repo.fetchAll()
		#expect(result.count == SkippedTaskEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyAfterRemovingAll() throws {
		let repo = MockSkippedTaskRepository()
		repo.items = []
		let result = try repo.fetchAll()
		#expect(result.isEmpty)
	}

	// MARK: - fetchAll(for:)

	@Test func fetchAllForTask_returnsItemsMatchingTaskId() throws {
		let repo = MockSkippedTaskRepository()
		let result = try repo.fetchAllForTaskId(RoomTaskEntity.mockId)
		// Both seeded entries reference RoomTaskEntity.mockId
		#expect(result.count == 2)
		#expect(result.allSatisfy { $0.taskId == RoomTaskEntity.mockId })
	}

	@Test func fetchAllForTask_returnsEmptyForUnknownTaskId() throws {
		let repo = MockSkippedTaskRepository()
		let result = try repo.fetchAllForTaskId(UUID())
		#expect(result.isEmpty)
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_insertsNewEntity() throws {
		let repo = MockSkippedTaskRepository()
		let newEntry = SkippedTaskEntity(
			id: UUID(),
			taskId: RoomTaskEntity.mockId,
			originalDate: .mock,
			skippedAt: .mock
		)
		try repo.save(newEntry)
		let all = try repo.fetchAll()
		#expect(all.contains { $0.id == newEntry.id })
	}

	@Test(.tags(.adding)) func save_upsertsExistingEntity() throws {
		let repo = MockSkippedTaskRepository()
		let existing = SkippedTaskEntity.mock
		let newSkippedAt = Date.mock.addingTimeInterval(7200)
		existing.skippedAt = newSkippedAt
		try repo.save(existing)
		let all = try repo.fetchAll()
		let found = all.first { $0.id == existing.id }
		#expect(found?.skippedAt == newSkippedAt)
	}

	@Test(.tags(.adding)) func save_doesNotDuplicateExistingEntity() throws {
		let repo = MockSkippedTaskRepository()
		let countBefore = repo.items.count
		let existing = SkippedTaskEntity.mock
		try repo.save(existing)
		#expect(repo.items.count == countBefore)
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesMatchingEntity() throws {
		let repo = MockSkippedTaskRepository()
		let target = SkippedTaskEntity.mock
		try repo.delete(target)
		let all = try repo.fetchAll()
		#expect(!all.contains { $0.id == target.id })
	}

	@Test(.tags(.deleting)) func delete_doesNotAffectOtherEntities() throws {
		let repo = MockSkippedTaskRepository()
		let countBefore = repo.items.count
		let target = SkippedTaskEntity.mock
		try repo.delete(target)
		#expect(repo.items.count == countBefore - 1)
	}

	@Test(.tags(.deleting)) func delete_noOpForNonExistentEntity() throws {
		let repo = MockSkippedTaskRepository()
		let countBefore = repo.items.count
		let ghost = SkippedTaskEntity(id: UUID(), taskId: UUID(), originalDate: .mock, skippedAt: .mock)
		try repo.delete(ghost)
		#expect(repo.items.count == countBefore)
	}
}
