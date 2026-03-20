import Foundation

@MainActor
final class MockRoomTaskRepository: RoomTaskRepository {
	// MARK: - Properties

	var items: [RoomTaskEntity] = []

	// MARK: - Methods

	func fetchAll() throws -> [RoomTaskEntity] {
		items
	}

	func fetchAll(for roomId: UUID) throws -> [RoomTaskEntity] {
		items.filter { $0.room?.id == roomId }
	}

	func save(_ item: RoomTaskEntity) throws {
		if let index = items.firstIndex(where: { $0.id == item.id }) {
			items[index] = item
		} else {
			items.append(item)
		}
	}

	func delete(_ item: RoomTaskEntity) throws {
		items.removeAll { $0.id == item.id }
	}
}
