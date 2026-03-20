import Foundation
import SwiftData

@MainActor
protocol RoomRepository {
	func fetchAll() throws -> [RoomEntity]
	func fetch(by id: UUID) throws -> RoomEntity?
	func save(_ item: RoomEntity) throws
	func delete(_ item: RoomEntity) throws
}

@MainActor
final class SwiftDataRoomRepository: RoomRepository {
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

	func fetchAll() throws -> [RoomEntity] {
		let descriptor = FetchDescriptor<RoomEntity>(sortBy: [SortDescriptor(\.createdAt)])
		let entities = try mainContext.fetch(descriptor)
		return entities
	}

	func fetch(by id: UUID) throws -> RoomEntity? {
		let descriptor = FetchDescriptor<RoomEntity>(
			predicate: #Predicate { $0.id == id },
			sortBy: [SortDescriptor(\.createdAt)]
		)
		let entity = try mainContext.fetch(descriptor).first
		return entity
	}

	func save(_ entity: RoomEntity) throws {
		mainContext.insert(entity)
		try mainContext.save()
	}

	func delete(_ entity: RoomEntity) throws {
		guard let existingEntity = try fetch(by: entity.id) else {
			return
		}
		mainContext.delete(existingEntity)
		try mainContext.save()
	}
}
