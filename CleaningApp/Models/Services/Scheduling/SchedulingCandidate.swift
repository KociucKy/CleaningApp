import Foundation

// MARK: - SchedulingCandidate

@MainActor
struct SchedulingCandidate: Identifiable, Equatable {
    // MARK: - Properties

    let id: UUID
    let task: RoomTask
    let kind: SchedulingCandidateKind
    let earliestDate: Date
    let originalScheduledDate: Date?
    let sourceOccurrenceId: UUID?

    var effectiveDuration: Int {
        task.learnedDuration ?? task.estimatedDuration.rawValue
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        task: RoomTask,
        kind: SchedulingCandidateKind,
        earliestDate: Date,
        originalScheduledDate: Date? = nil,
        sourceOccurrenceId: UUID? = nil
    ) {
        self.id = id
        self.task = task
        self.kind = kind
        self.earliestDate = earliestDate
        self.originalScheduledDate = originalScheduledDate
        self.sourceOccurrenceId = sourceOccurrenceId
    }
}
