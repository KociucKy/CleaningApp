import Foundation
import SwiftData

// MARK: - RoomRepository

@MainActor
protocol RoomRepository {
    func fetchAll() throws -> [Room]
    func save(_ item: Room) throws
    func delete(_ item: Room) throws
}

// MARK: - MockRoomRepository

@MainActor
final class MockRoomRepository: RoomRepository {

    // MARK: - Properties

    var items: [Room] = []

    // MARK: - RoomRepository

    func fetchAll() throws -> [Room] {
        items
    }

    func save(_ item: Room) throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func delete(_ item: Room) throws {
        items.removeAll { $0.id == item.id }
    }
}

// MARK: - SwiftDataRoomRepository

@MainActor
final class SwiftDataRoomRepository: RoomRepository {

    // MARK: - Properties

    private let container: ModelContainer

    // MARK: - Init

    init(container: ModelContainer) {
        self.container = container
    }

    // MARK: - RoomRepository

    func fetchAll() throws -> [Room] {
        let context = container.mainContext
        let entities = try context.fetch(FetchDescriptor<RoomEntity>())
        return entities.map(RoomMapper.toDomain)
    }

    func save(_ item: Room) throws {
        let context = container.mainContext
        let entity = RoomMapper.toEntity(item)
        context.insert(entity)
        try context.save()
    }

    func delete(_ item: Room) throws {
        let context = container.mainContext
        let entities = try context.fetch(FetchDescriptor<RoomEntity>())
        if let entity = entities.first(where: { $0.id == item.id }) {
            context.delete(entity)
            try context.save()
        }
    }
}