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

    func makeRegularCandidates(
        input: SchedulingInput,
        horizon: SchedulingHorizon,
        analysis: SchedulingOccurrenceAnalysis,
        urgentCandidates: [SchedulingCandidate],
        recurrenceCalculator: SchedulingRecurrenceCalculator
    ) -> [SchedulingCandidate] {
        input.tasks
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .flatMap { task -> [SchedulingCandidate] in
                let activationDate = max(
                    horizon.startDate,
                    input.calendar.startOfDay(for: task.createdAt)
                )
                guard activationDate <= horizon.endDate else {
                    return []
                }

                let demand = regularDemand(
                    for: task,
                    activationDate: activationDate,
                    horizon: horizon,
                    calendar: input.calendar,
                    recurrenceCalculator: recurrenceCalculator
                )
                let fulfilledCount = fulfilledCount(
                    for: task.id,
                    fulfillmentStartDate: demand.fulfillmentStartDate,
                    horizon: horizon,
                    completedTasks: input.completedTasks,
                    preservedOccurrences: analysis.preservedOccurrences,
                    urgentCandidates: urgentCandidates,
                    calendar: input.calendar
                )
                let candidateCount = max(0, demand.targetCount - fulfilledCount)

                return (0 ..< candidateCount).map { _ in
                    SchedulingCandidate(
                        task: task,
                        kind: .regular,
                        earliestDate: activationDate
                    )
                }
            }
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

    private func regularDemand(
        for task: RoomTask,
        activationDate: Date,
        horizon: SchedulingHorizon,
        calendar: Calendar,
        recurrenceCalculator: SchedulingRecurrenceCalculator
    ) -> (targetCount: Int, fulfillmentStartDate: Date) {
        switch recurrenceCalculator.rule(for: task.frequency) {
        case .intervalDays(1):
            let targetCount = calendar.dateComponents(
                [.day],
                from: activationDate,
                to: horizon.endDate
            ).day.map { $0 + 1 } ?? 0
            return (targetCount, activationDate)
        case let .intervalDays(interval):
            let activeDays = calendar.dateComponents(
                [.day],
                from: activationDate,
                to: horizon.endDate
            ).day.map { $0 + 1 } ?? 0
            return (Int((Double(activeDays) / Double(interval)).rounded()), activationDate)
        case let .weeklyQuota(count):
            let activeDays = calendar.dateComponents(
                [.day],
                from: activationDate,
                to: horizon.endDate
            ).day.map { $0 + 1 } ?? 0
            return (
                recurrenceCalculator.proRatedQuota(
                    totalOccurrences: count,
                    activeDays: activeDays,
                    periodDays: 7
                ),
                activationDate
            )
        case let .monthlyQuota(count):
            return monthlyQuotaDemand(
                count: count,
                taskCreatedAt: task.createdAt,
                horizon: horizon,
                calendar: calendar,
                recurrenceCalculator: recurrenceCalculator
            )
        case .intervalWeeks, .intervalMonths:
            return (0, activationDate)
        }
    }

    private func monthlyQuotaDemand(
        count: Int,
        taskCreatedAt: Date,
        horizon: SchedulingHorizon,
        calendar: Calendar,
        recurrenceCalculator: SchedulingRecurrenceCalculator
    ) -> (targetCount: Int, fulfillmentStartDate: Date) {
        guard let monthInterval = calendar.dateInterval(of: .month, for: horizon.endDate),
              let monthEndDate = calendar.date(byAdding: .day, value: -1, to: monthInterval.end)
        else {
            return (0, horizon.startDate)
        }

        let fulfillmentStartDate = max(
            monthInterval.start,
            calendar.startOfDay(for: taskCreatedAt)
        )
        let activePeriodDays = calendar.dateComponents(
            [.day],
            from: fulfillmentStartDate,
            to: monthEndDate
        ).day.map { $0 + 1 } ?? 0
        let activeDaysThroughHorizon = calendar.dateComponents(
            [.day],
            from: fulfillmentStartDate,
            to: horizon.endDate
        ).day.map { $0 + 1 } ?? 0
        let firstPeriodQuota = recurrenceCalculator.proRatedQuota(
            totalOccurrences: count,
            activeDays: activePeriodDays,
            periodDays: calendar.range(of: .day, in: .month, for: horizon.endDate)?.count ?? 0
        )
        let targetCount = recurrenceCalculator.proRatedQuota(
            totalOccurrences: firstPeriodQuota,
            activeDays: activeDaysThroughHorizon,
            periodDays: activePeriodDays
        )

        return (targetCount, fulfillmentStartDate)
    }

    private func fulfilledCount(
        for taskID: UUID,
        fulfillmentStartDate: Date,
        horizon: SchedulingHorizon,
        completedTasks: [CompletedTask],
        preservedOccurrences: [ScheduledTask],
        urgentCandidates: [SchedulingCandidate],
        calendar: Calendar
    ) -> Int {
        let completionCount = completedTasks.filter {
            let completionDate = calendar.startOfDay(for: $0.completedAt)
            return $0.taskId == taskID
                && completionDate >= fulfillmentStartDate
                && completionDate <= horizon.endDate
        }.count
        let preservedCount = preservedOccurrences.filter {
            $0.taskId == taskID && $0.scheduledDate >= fulfillmentStartDate
        }.count
        let urgentCount = urgentCandidates.filter { $0.task.id == taskID }.count

        return completionCount + preservedCount + urgentCount
    }
}
