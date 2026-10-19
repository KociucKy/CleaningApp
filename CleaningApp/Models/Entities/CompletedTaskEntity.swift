import Foundation
import SwiftData

@Model
final class CompletedTaskEntity {
    // MARK: - Properties

    var id: UUID
    var taskId: UUID
    var roomId: UUID?
    var roomName: String?
    var taskName: String?
    var scheduledTaskId: UUID?
    var completedAt: Date
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
