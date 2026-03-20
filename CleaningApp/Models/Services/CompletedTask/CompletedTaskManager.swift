import Foundation

@MainActor
final class CompletedTaskManager {
	// MARK: - Properties

	private let repository: any CompletedTaskRepository
	private let mapper: CompletedTaskMapper

	// MARK: - Init

	init(
		repository: any CompletedTaskRepository,
		mapper: CompletedTaskMapper = CompletedTaskMapper()
	) {
		self.repository = repository
		self.mapper = mapper
	}

	// MARK: - Methods

	func fetchAll() throws -> [CompletedTask] {
		let entities = try repository.fetchAll()
		let models = entities.map(mapper.toDomain)
		return models
	}

	func fetchAll(for taskId: UUID) throws -> [CompletedTask] {
		let entities = try repository.fetchAll(for: taskId)
		let models = entities.map(mapper.toDomain)
		return models
	}

	func save(_ item: CompletedTask) throws {
		let entity = mapper.toEntity(item)
		try repository.save(entity)
	}

	func delete(_ item: CompletedTask) throws {
		let entity = mapper.toEntity(item)
		try repository.delete(entity)
	}
}
