import Foundation

struct CompletedTaskMapper {
	func toDomain(_ entity: CompletedTaskEntity) -> CompletedTask {
		CompletedTask(
			id: entity.id,
			taskId: entity.taskId,
			completedAt: entity.completedAt,
			measuredDuration: entity.measuredDuration
		)
	}

	func toEntity(_ domain: CompletedTask) -> CompletedTaskEntity {
		CompletedTaskEntity(
			id: domain.id,
			taskId: domain.taskId,
			completedAt: domain.completedAt,
			measuredDuration: domain.measuredDuration
		)
	}
}
