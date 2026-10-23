import Foundation

struct CompletedTask: Identifiable {
    // MARK: - Properties

    let id: UUID
    let taskId: UUID
    let roomId: UUID?
    let roomName: String?
    let taskName: String?
    let scheduledTaskId: UUID?
    let completedAt: Date
    var measuredDuration: Int?

    // MARK: - Init

    init(
        id: UUID = UUID(),
        taskId: UUID,
        roomId: UUID? = nil,
        roomName: String? = nil,
        taskName: String? = nil,
        scheduledTaskId: UUID? = nil,
        completedAt: Date = Date(),
        measuredDuration: Int? = nil
    ) {
        self.id = id
        self.taskId = taskId
        self.roomId = roomId
        self.roomName = roomName
        self.taskName = taskName
        self.scheduledTaskId = scheduledTaskId
        self.completedAt = completedAt
        self.measuredDuration = measuredDuration
    }
}
