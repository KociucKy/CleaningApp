import Foundation

@MainActor
final class MockCompletedTaskRepository: CompletedTaskRepository {
	// MARK: - Properties

	var items: [CompletedTaskEntity] = []

	// MARK: - CompletedTaskRepository

	func fetchAll() throws -> [CompletedTaskEntity] {
		items
	}

	func fetchAll(for taskId: UUID) throws -> [CompletedTaskEntity] {
		items.filter { $0.taskId == taskId }
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
