import Foundation

// MARK: - ScheduledTask

@MainActor
struct ScheduledTask: Identifiable, Equatable, Hashable {
    // MARK: - Properties

    let id: UUID
    let taskId: UUID
    let scheduledDate: Date
    let originalScheduledDate: Date
    var status: ScheduledTaskStatus
    let sourceOccurrenceId: UUID?
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Init

    init(
        id: UUID = UUID(),
        taskId: UUID,
        scheduledDate: Date,
        originalScheduledDate: Date? = nil,
        status: ScheduledTaskStatus = .planned,
        sourceOccurrenceId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.taskId = taskId
        self.scheduledDate = scheduledDate
        self.originalScheduledDate = originalScheduledDate ?? scheduledDate
        self.status = status
        self.sourceOccurrenceId = sourceOccurrenceId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
