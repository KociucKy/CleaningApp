import Foundation

// MARK: - SchedulingCandidateGenerator

@MainActor
final class SchedulingCandidateGenerator {
    // MARK: - Methods

    func makeUrgentCandidates(
        tasks: [RoomTask],
        analysis: SchedulingOccurrenceAnalysis,
        horizon: SchedulingHorizon
    ) -> [SchedulingCandidate] {
        let tasksByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        let backlogCandidates = makeCandidates(
            from: earliestOccurrencesByTask(analysis.backlogOccurrences),
            tasksByID: tasksByID,
            kind: .backlog,
            earliestDate: horizon.startDate
        )
        let backlogTaskIDs = Set(backlogCandidates.map(\.task.id))
        let overdueOccurrences = analysis.overdueOccurrences.filter {
            !backlogTaskIDs.contains($0.taskId)
        }
        let overdueCandidates = makeCandidates(
            from: earliestOccurrencesByTask(overdueOccurrences),
            tasksByID: tasksByID,
            kind: .overdue,
            earliestDate: horizon.startDate
        )

        return backlogCandidates + overdueCandidates
    }

    // MARK: - Private

    private func earliestOccurrencesByTask(
        _ occurrences: [ScheduledTask]
    ) -> [ScheduledTask] {
        let earliestByTask = occurrences.reduce(into: [UUID: ScheduledTask]()) { result, occurrence in
            guard let existing = result[occurrence.taskId] else {
                result[occurrence.taskId] = occurrence
                return
            }

            if occurrence.originalScheduledDate < existing.originalScheduledDate {
                result[occurrence.taskId] = occurrence
            }
        }

        return earliestByTask.values.sorted {
            if $0.originalScheduledDate != $1.originalScheduledDate {
                return $0.originalScheduledDate < $1.originalScheduledDate
            }
            return $0.id.uuidString < $1.id.uuidString
        }
    }

    private func makeCandidates(
        from occurrences: [ScheduledTask],
        tasksByID: [UUID: RoomTask],
        kind: SchedulingCandidateKind,
        earliestDate: Date
    ) -> [SchedulingCandidate] {
        occurrences.compactMap { occurrence in
            guard let task = tasksByID[occurrence.taskId] else {
                return nil
            }

            return SchedulingCandidate(
                id: occurrence.id,
                task: task,
                kind: kind,
                earliestDate: earliestDate,
                originalScheduledDate: occurrence.originalScheduledDate,
                sourceOccurrenceId: occurrence.id
            )
        }
    }
}
