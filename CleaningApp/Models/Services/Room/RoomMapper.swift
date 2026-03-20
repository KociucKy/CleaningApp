import Foundation

struct RoomMapper {
	func toDomain(_ entity: RoomEntity) -> Room {
		Room(
			id: entity.id,
			name: entity.name,
			icon: RoomIcon(rawValue: entity.icon) ?? .custom,
			createdAt: entity.createdAt
		)
	}

	func toEntity(_ domain: Room) -> RoomEntity {
		RoomEntity(
			id: domain.id,
			name: domain.name,
			icon: domain.icon.rawValue,
			createdAt: domain.createdAt
		)
	}
}
