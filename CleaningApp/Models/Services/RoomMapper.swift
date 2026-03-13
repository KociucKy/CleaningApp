import Foundation

// MARK: - RoomMapper

enum RoomMapper {

    static func toDomain(_ entity: RoomEntity) -> Room {
        Room(
            id: entity.id,
            createdAt: entity.createdAt
        )
    }

    static func toEntity(_ domain: Room) -> RoomEntity {
        RoomEntity(
            id: domain.id,
            createdAt: domain.createdAt
        )
    }
}