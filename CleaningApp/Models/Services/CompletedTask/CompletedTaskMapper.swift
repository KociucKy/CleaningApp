import Foundation

struct CompletedTaskMapper {
    func toDomain(_ entity: CompletedTaskEntity) -> CompletedTask {
        CompletedTask(
            id: entity.id,
            taskId: entity.taskId,
            roomId: entity.roomId,
            roomName: entity.roomName,
            taskName: entity.taskName,
            scheduledTaskId: entity.scheduledTaskId,
            completedAt: entity.completedAt,
            measuredDuration: entity.measuredDuration
        )
    }

    func toEntity(_ domain: CompletedTask) -> CompletedTaskEntity {
        CompletedTaskEntity(
            id: domain.id,
            taskId: domain.taskId,
            roomId: domain.roomId,
            roomName: domain.roomName,
            taskName: domain.taskName,
            scheduledTaskId: domain.scheduledTaskId,
            completedAt: domain.completedAt,
            measuredDuration: domain.measuredDuration
        )
    }
}
