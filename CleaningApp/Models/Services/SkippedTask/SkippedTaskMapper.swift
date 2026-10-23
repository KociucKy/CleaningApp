import Foundation

struct SkippedTaskMapper {
	func toDomain(_ entity: SkippedTaskEntity) -> SkippedTask {
		SkippedTask(
			id: entity.id,
			taskId: entity.taskId,
			scheduledTaskId: entity.scheduledTaskId,
			originalDate: entity.originalDate,
			skippedAt: entity.skippedAt
		)
	}

	func toEntity(_ domain: SkippedTask) -> SkippedTaskEntity {
		SkippedTaskEntity(
			id: domain.id,
			taskId: domain.taskId,
			scheduledTaskId: domain.scheduledTaskId,
			originalDate: domain.originalDate,
			skippedAt: domain.skippedAt
		)
	}
}
