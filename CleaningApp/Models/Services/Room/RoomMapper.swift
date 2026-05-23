import Foundation

struct RoomMapper {
	func toDomain(_ entity: RoomEntity) -> Room {
		Room(
			id: entity.id,
			name: entity.name,
			kind: RoomType(rawValue: entity.icon) ?? .customRoom,
			isCustom: entity.isCustom,
			customIcon: entity.customIcon,
			createdAt: entity.createdAt
		)
	}

	func toEntity(_ domain: Room) -> RoomEntity {
		RoomEntity(
			id: domain.id,
			name: domain.name,
			icon: domain.kind.rawValue,
			isCustom: domain.isCustom,
			customIcon: domain.customIcon,
			createdAt: domain.createdAt
		)
	}
}
