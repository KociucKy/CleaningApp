import Foundation

@MainActor
final class MockRoomRepository: RoomRepository {
	// MARK: - Properties

	var items: [RoomEntity]
	var error: Error?

	// MARK: - Init
	init(
		items: [RoomEntity] = RoomEntity.mocks,
		error: Error? = nil
	) {
		self.items = items
		self.error = error
	}

	// MARK: - Methods

	func fetchAll() throws -> [RoomEntity] {
		guard error == nil else { throw error! }
		return items
	}

	func fetch(by id: UUID) throws -> RoomEntity? {
		items.first(where: { $0.id == id })
	}

	func save(_ item: RoomEntity) throws {
		if let index = items.firstIndex(where: { $0.id == item.id }) {
			items[index] = item
		} else {
			items.append(item)
		}
	}

	func delete(_ item: RoomEntity) throws {
		items.removeAll { $0.id == item.id }
	}
}
