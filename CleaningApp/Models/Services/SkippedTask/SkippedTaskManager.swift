import Foundation

@MainActor
final class SkippedTaskManager {
	// MARK: - Properties

	private let repository: any SkippedTaskRepository
	private let mapper: SkippedTaskMapper

	// MARK: - Init

	init(
		repository: any SkippedTaskRepository,
		mapper: SkippedTaskMapper = SkippedTaskMapper()
	) {
		self.repository = repository
		self.mapper = mapper
	}

	// MARK: - Methods

	func fetchAll() throws -> [SkippedTask] {
		let entities = try repository.fetchAll()
		return entities.map(mapper.toDomain)
	}

	func fetchAll(for taskId: UUID) throws -> [SkippedTask] {
		let entities = try repository.fetchAllForTaskId(taskId)
		return entities.map(mapper.toDomain)
	}

	func save(_ item: SkippedTask) throws {
		let entity = mapper.toEntity(item)
		try repository.save(entity)
	}

	func delete(_ item: SkippedTask) throws {
		let entity = mapper.toEntity(item)
		try repository.delete(entity)
	}
}
