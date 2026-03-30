import Foundation

@MainActor
final class MockCompletedTaskRepository: CompletedTaskRepository {
	// MARK: - Properties

	var items: [CompletedTaskEntity] = CompletedTaskEntity.mocks

	// MARK: - CompletedTaskRepository

	func fetchAll() throws -> [CompletedTaskEntity] {
		items
	}

	func fetchAllForTaskId(_ id: UUID) throws -> [CompletedTaskEntity] {
		items.filter { $0.taskId == id }
	}

	func fetchSingle(for id: UUID) throws -> CompletedTaskEntity? {
		items.filter { $0.id == id }.first
	}

	func save(_ item: CompletedTaskEntity) throws {
		if let index = items.firstIndex(where: { $0.id == item.id }) {
			items[index] = item
		} else {
			items.append(item)
		}
	}

	func delete(_ item: CompletedTaskEntity) throws {
		items.removeAll { $0.id == item.id }
	}
}
