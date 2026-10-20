import Foundation

// MARK: - ScheduledTaskMapper

@MainActor
struct ScheduledTaskMapper {
    // MARK: - Methods

    func toDomain(_ entity: ScheduledTaskEntity) -> ScheduledTask {
        ScheduledTask(
            id: entity.id,
            taskId: entity.taskId,
            scheduledDate: entity.scheduledDate,
            originalScheduledDate: entity.originalScheduledDate,
            status: ScheduledTaskStatus(rawValue: entity.statusEncoded) ?? .planned,
            sourceOccurrenceId: entity.sourceOccurrenceId,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }

    func toEntity(_ domain: ScheduledTask) -> ScheduledTaskEntity {
        ScheduledTaskEntity(
            id: domain.id,
            taskId: domain.taskId,
            scheduledDate: domain.scheduledDate,
            originalScheduledDate: domain.originalScheduledDate,
            statusEncoded: domain.status.rawValue,
            sourceOccurrenceId: domain.sourceOccurrenceId,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
