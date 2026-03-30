import Foundation
import Testing
@testable import CleaningApp

// MARK: - CompletedTaskManagerTests

@Suite(.tags(.persistence))
@MainActor
struct CompletedTaskManagerTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsMappedDomainModels() throws {
		let manager = CompletedTaskManager(repository: MockCompletedTaskRepository())
		let tasks = try manager.fetchAll()
		#expect(tasks.count == CompletedTaskEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyWhenRepositoryIsEmpty() throws {
		let repo = MockCompletedTaskRepository()
		repo.items = []
		let manager = CompletedTaskManager(repository: repo)
		#expect(try manager.fetchAll().isEmpty)
	}

	@Test func fetchAll_mapsIdAndTaskIdCorrectly() throws {
		let manager = CompletedTaskManager(repository: MockCompletedTaskRepository())
		let tasks = try manager.fetchAll()
		let ids = tasks.map(\.id)
		let entityIds = CompletedTaskEntity.mocks.map(\.id)
		#expect(Set(ids) == Set(entityIds))
	}

	// MARK: - fetchAll(for:)

	@Test func fetchAllForTask_returnsMatchingDomainModels() throws {
		let manager = CompletedTaskManager(repository: MockCompletedTaskRepository())
		let tasks = try manager.fetchAll(for: RoomTask.mockId)
		#expect(tasks.count == 2)
		#expect(tasks.allSatisfy { $0.taskId == RoomTask.mockId })
	}

	@Test func fetchAllForTask_returnsEmptyForUnknownTaskId() throws {
		let manager = CompletedTaskManager(repository: MockCompletedTaskRepository())
		let tasks = try manager.fetchAll(for: UUID())
		#expect(tasks.isEmpty)
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_persistsNewEntry() throws {
		let repo = MockCompletedTaskRepository()
		repo.items = []
		let manager = CompletedTaskManager(repository: repo)
		let entry = CompletedTask(
			id: UUID(),
			taskId: RoomTask.mockId,
			completedAt: .mock,
			measuredDuration: 30
		)
		try manager.save(entry)
		let all = try manager.fetchAll()
		#expect(all.contains { $0.id == entry.id })
	}

	@Test(.tags(.adding)) func save_upsertsExistingEntry() throws {
		let manager = CompletedTaskManager(repository: MockCompletedTaskRepository())
		var entry = try #require(CompletedTask.mocks.first)
		entry = CompletedTask(
			id: entry.id,
			taskId: entry.taskId,
			completedAt: entry.completedAt,
			measuredDuration: 77
		)
		try manager.save(entry)
		let all = try manager.fetchAll()
		let found = all.first { $0.id == entry.id }
		#expect(found?.measuredDuration == 77)
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesEntry() throws {
		let manager = CompletedTaskManager(repository: MockCompletedTaskRepository())
		let entry = try #require(CompletedTask.mocks.first)
		let countBefore = try manager.fetchAll().count
		try manager.delete(entry)
		let countAfter = try manager.fetchAll().count
		#expect(countAfter == countBefore - 1)
	}

	@Test(.tags(.deleting)) func delete_doesNotAffectOtherEntries() throws {
		let manager = CompletedTaskManager(repository: MockCompletedTaskRepository())
		let entry = try #require(CompletedTask.mocks.first)
		try manager.delete(entry)
		let remaining = try manager.fetchAll()
		#expect(!remaining.contains { $0.id == entry.id })
	}
}
