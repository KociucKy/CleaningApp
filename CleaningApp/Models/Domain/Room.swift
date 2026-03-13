import Foundation

// MARK: - Room

struct Room: Identifiable, Equatable {

    // MARK: - Properties

    let id: UUID
    var createdAt: Date

    // MARK: - Init

    init(id: UUID = UUID(), createdAt: Date = Date()) {
        self.id = id
        self.createdAt = createdAt
    }
}