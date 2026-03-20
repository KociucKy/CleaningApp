import Foundation
import SwiftData


@MainActor
protocol RoomTaskRepository {
	func fetchAll() throws -> [RoomTaskEntity]
	func fetchAll(for roomId: UUID) throws -> [RoomTaskEntity]
	func save(_ item: RoomTaskEntity) throws
	func delete(_ item: RoomTaskEntity) throws
}

@MainActor
final class SwiftDataRoomTaskRepository: RoomTaskRepository {
	// MARK: - Properties

	private let container: ModelContainer
	private var mainContext: ModelContext {
		container.mainContext
	}

	// MARK: - Init

	init(container: ModelContainer) {
		self.container = container
	}

	// MARK: - Methods

	func fetchAll() throws -> [RoomTaskEntity] {
		let descriptor = FetchDescriptor<RoomTaskEntity>(
			sortBy: [SortDescriptor(\.createdAt)]
		)
		let entities = try mainContext.fetch(descriptor)
		return entities
	}

	func fetchAll(for roomId: UUID) throws -> [RoomTaskEntity] {
		let descriptor = FetchDescriptor<RoomTaskEntity>(
			predicate: #Predicate { $0.id == roomId },
			sortBy: [SortDescriptor(\.createdAt)]
		)
		let entities = try mainContext.fetch(descriptor)
		return entities
	}

	func save(_ entity: RoomTaskEntity) throws {
		mainContext.insert(entity)
		try mainContext.save()
	}

	func delete(_ entity: RoomTaskEntity) throws {
		guard let existingEntity = try fetchAll(for: entity.room.id).first else {
			return
		}
		mainContext.delete(existingEntity)
		try mainContext.save()
	}
}
