import Foundation

struct SkippedTaskMapper {
	func toDomain(_ entity: SkippedTaskEntity) -> SkippedTask {
		SkippedTask(
			id: entity.id,
			taskId: entity.taskId,
			originalDate: entity.originalDate,
			skippedAt: entity.skippedAt
		)
	}

	func toEntity(_ domain: SkippedTask) -> SkippedTaskEntity {
		SkippedTaskEntity(
			id: domain.id,
			taskId: domain.taskId,
			originalDate: domain.originalDate,
			skippedAt: domain.skippedAt
		)
	}
}
