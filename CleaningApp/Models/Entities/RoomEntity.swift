import SwiftData
import Foundation

// MARK: - RoomEntity

@Model
final class RoomEntity {

    // MARK: - Properties

    var id: UUID
    var createdAt: Date

    // MARK: - Init

    init(id: UUID = UUID(), createdAt: Date = Date()) {
        self.id = id
        self.createdAt = createdAt
    }
}