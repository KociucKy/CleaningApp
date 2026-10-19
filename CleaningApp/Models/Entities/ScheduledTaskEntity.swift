import Foundation
import SwiftData

// MARK: - ScheduledTaskEntity

@Model
final class ScheduledTaskEntity {
    // MARK: - Properties

    var id: UUID
    var taskId: UUID
    var scheduledDate: Date
    var originalScheduledDate: Date
    var statusEncoded: String
    var sourceOccurrenceId: UUID?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Init

    init(
        id: UUID = UUID(),
        taskId: UUID,
        scheduledDate: Date,
        originalScheduledDate: Date,
        statusEncoded: String,
        sourceOccurrenceId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.taskId = taskId
        self.scheduledDate = scheduledDate
        self.originalScheduledDate = originalScheduledDate
        self.statusEncoded = statusEncoded
        self.sourceOccurrenceId = sourceOccurrenceId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
