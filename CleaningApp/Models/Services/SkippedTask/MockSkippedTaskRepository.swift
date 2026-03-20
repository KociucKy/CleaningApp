#if MOCK
	import Foundation

	@MainActor
	final class MockSkippedTaskRepository: SkippedTaskRepository {
		// MARK: - Properties

		var items: [SkippedTaskEntity] = SkippedTaskEntity.mocks

		// MARK: - Methods

		func fetchAll() throws -> [SkippedTaskEntity] {
			items
		}

		func fetchAll(for taskId: UUID) throws -> [SkippedTaskEntity] {
			items.filter { $0.taskId == taskId }
		}

		func save(_ item: SkippedTaskEntity) throws {
			if let index = items.firstIndex(where: { $0.id == item.id }) {
				items[index] = item
			} else {
				items.append(item)
			}
		}

		func delete(_ item: SkippedTaskEntity) throws {
			items.removeAll { $0.id == item.id }
		}
	}
#endif
