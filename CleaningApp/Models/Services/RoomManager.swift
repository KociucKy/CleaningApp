import Foundation

// MARK: - RoomManager

@MainActor
final class RoomManager {

    // MARK: - Properties

    private let repository: any RoomRepository

    // MARK: - Init

    init(repository: any RoomRepository) {
        self.repository = repository
    }

    // MARK: - Methods

    func fetchAll() throws -> [Room] {
        try repository.fetchAll()
    }

    func save(_ item: Room) throws {
        try repository.save(item)
    }

    func delete(_ item: Room) throws {
        try repository.delete(item)
    }
}