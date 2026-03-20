#if MOCK
	import Foundation

	@MainActor
	final class MockRoomRepository: RoomRepository {
		// MARK: - Properties

		var items: [RoomEntity] = RoomEntity.mocks

		// MARK: - Methods

		func fetchAll() throws -> [RoomEntity] {
			items
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
#endif
