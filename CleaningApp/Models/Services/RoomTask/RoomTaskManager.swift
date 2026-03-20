import Foundation

@MainActor
final class RoomTaskManager {
	// MARK: - Properties

	private let taskRepository: any RoomTaskRepository
	private let roomRepository: any RoomRepository
	private let mapper: RoomTaskMapper

	// MARK: - Init

	init(
		taskRepository: any RoomTaskRepository,
		roomRepository: any RoomRepository,
		mapper: RoomTaskMapper
	) {
		self.taskRepository = taskRepository
		self.roomRepository = roomRepository
		self.mapper = mapper
	}

	// MARK: - Methods

	func fetchAll() throws -> [RoomTask] {
		let entities = try taskRepository.fetchAll()
		let models = entities.map(mapper.toDomain)
		return models
	}

	func fetchAll(for roomId: UUID) throws -> [RoomTask] {
		let entities = try taskRepository.fetchAll(for: roomId)
		let models = entities.map(mapper.toDomain)
		return models
	}

	func save(_ model: RoomTask) throws {
		guard let roomEntity = try roomRepository.fetch(by: model.roomId) else {
			return
		}
		let entity = mapper.toEntity(model, roomEntity: roomEntity)
		try taskRepository.save(entity)
	}

	func delete(_ model: RoomTask) throws {
		guard let roomEntity = try roomRepository.fetch(by: model.roomId) else {
			return
		}
		let entity = mapper.toEntity(model, roomEntity: roomEntity)
		try taskRepository.delete(entity)
	}
}
