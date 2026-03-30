import Foundation

struct RoomTaskMapper {
	private let frequencyEncoder: FrequencyEncoder

	init(
		frequencyEncoder: FrequencyEncoder = FrequencyEncoder()
	) {
		self.frequencyEncoder = frequencyEncoder
	}

	func toDomain(_ entity: RoomTaskEntity) -> RoomTask {
		RoomTask(
			id: entity.id,
			name: entity.name,
			roomId: entity.room?.id ?? UUID(),
			frequency: frequencyEncoder.decode(entity.frequencyEncoded),
			estimatedDuration: TaskDuration(rawValue: entity.estimatedDuration) ?? .fifteenMinutes,
			createdAt: entity.createdAt
		)
	}

	func toEntity(_ domain: RoomTask, roomEntity: RoomEntity) -> RoomTaskEntity {
		RoomTaskEntity(
			id: domain.id,
			name: domain.name,
			room: roomEntity,
			frequencyEncoded: frequencyEncoder.encode(domain.frequency),
			estimatedDuration: domain.estimatedDuration.rawValue,
			createdAt: domain.createdAt
		)
	}
}
