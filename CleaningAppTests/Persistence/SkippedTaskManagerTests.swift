import Foundation
import Testing
@testable import CleaningApp

// MARK: - SkippedTaskManagerTests

@Suite(.tags(.persistence))
@MainActor
struct SkippedTaskManagerTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsMappedDomainModels() throws {
		let manager = SkippedTaskManager(repository: MockSkippedTaskRepository())
		let tasks = try manager.fetchAll()
		#expect(tasks.count == SkippedTaskEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyWhenRepositoryIsEmpty() throws {
		let repo = MockSkippedTaskRepository()
		repo.items = []
		let manager = SkippedTaskManager(repository: repo)
		#expect(try manager.fetchAll().isEmpty)
	}

	@Test func fetchAll_mapsIdAndTaskIdCorrectly() throws {
		let manager = SkippedTaskManager(repository: MockSkippedTaskRepository())
		let tasks = try manager.fetchAll()
		let ids = tasks.map(\.id)
		let entityIds = SkippedTaskEntity.mocks.map(\.id)
		#expect(Set(ids) == Set(entityIds))
	}

	// MARK: - fetchAll(for:)

	@Test func fetchAllForTask_returnsMatchingDomainModels() throws {
		let manager = SkippedTaskManager(repository: MockSkippedTaskRepository())
		let tasks = try manager.fetchAll(for: RoomTask.mockId)
		#expect(tasks.count == 2)
		#expect(tasks.allSatisfy { $0.taskId == RoomTask.mockId })
	}

	@Test func fetchAllForTask_returnsEmptyForUnknownTaskId() throws {
		let manager = SkippedTaskManager(repository: MockSkippedTaskRepository())
		let tasks = try manager.fetchAll(for: UUID())
		#expect(tasks.isEmpty)
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_persistsNewEntry() throws {
		let repo = MockSkippedTaskRepository()
		repo.items = []
		let manager = SkippedTaskManager(repository: repo)
		let entry = SkippedTask(
			id: UUID(),
			taskId: RoomTask.mockId,
			originalDate: .mock,
			skippedAt: .mock
		)
		try manager.save(entry)
		let all = try manager.fetchAll()
		#expect(all.contains { $0.id == entry.id })
	}

	@Test(.tags(.adding)) func save_upsertsExistingEntry() throws {
		let manager = SkippedTaskManager(repository: MockSkippedTaskRepository())
		let existing = try #require(SkippedTask.mocks.first)
		let newSkippedAt = Date.mock.addingTimeInterval(9999)
		let updated = SkippedTask(
			id: existing.id,
			taskId: existing.taskId,
			originalDate: existing.originalDate,
			skippedAt: newSkippedAt
		)
		try manager.save(updated)
		let all = try manager.fetchAll()
		let found = all.first { $0.id == existing.id }
		#expect(found?.skippedAt == newSkippedAt)
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesEntry() throws {
		let manager = SkippedTaskManager(repository: MockSkippedTaskRepository())
		let entry = try #require(SkippedTask.mocks.first)
		let countBefore = try manager.fetchAll().count
		try manager.delete(entry)
		let countAfter = try manager.fetchAll().count
		#expect(countAfter == countBefore - 1)
	}

	@Test(.tags(.deleting)) func delete_doesNotAffectOtherEntries() throws {
		let manager = SkippedTaskManager(repository: MockSkippedTaskRepository())
		let entry = try #require(SkippedTask.mocks.first)
		try manager.delete(entry)
		let remaining = try manager.fetchAll()
		#expect(!remaining.contains { $0.id == entry.id })
	}
}
