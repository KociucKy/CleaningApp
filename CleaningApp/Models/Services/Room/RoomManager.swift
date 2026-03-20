import Foundation

@MainActor
final class RoomManager {

	// MARK: - Properties

	private let repository: any RoomRepository
	private let mapper: RoomMapper

	// MARK: - Init

	init(
		repository: any RoomRepository,
		mapper: RoomMapper = RoomMapper()
	) {
		self.repository = repository
		self.mapper = mapper
	}

	// MARK: - Methods

	func fetchAll() throws -> [Room] {
		let entities = try repository.fetchAll()
		let models = entities.map(mapper.toDomain)
		return models
	}

	func save(_ item: Room) throws {
		let entity = mapper.toEntity(item)
		try repository.save(entity)
	}

	func delete(_ item: Room) throws {
		let entity = mapper.toEntity(item)
		try repository.delete(entity)
	}
}
