import Foundation

// MARK: - SchedulingService

@MainActor
final class SchedulingService {
    // MARK: - Properties

    private let occurrenceAnalyzer: SchedulingOccurrenceAnalyzer
    private let candidateGenerator: SchedulingCandidateGenerator
    private let candidateAllocator: SchedulingCandidateAllocator
    private let recurrenceCalculator: SchedulingRecurrenceCalculator

    // MARK: - Init

    init(
        occurrenceAnalyzer: SchedulingOccurrenceAnalyzer = SchedulingOccurrenceAnalyzer(),
        candidateGenerator: SchedulingCandidateGenerator = SchedulingCandidateGenerator(),
        candidateAllocator: SchedulingCandidateAllocator = SchedulingCandidateAllocator(),
        recurrenceCalculator: SchedulingRecurrenceCalculator = SchedulingRecurrenceCalculator()
    ) {
        self.occurrenceAnalyzer = occurrenceAnalyzer
        self.candidateGenerator = candidateGenerator
        self.candidateAllocator = candidateAllocator
        self.recurrenceCalculator = recurrenceCalculator
    }

    // MARK: - Methods

    func makeHorizon(today: Date, calendar: Calendar) -> SchedulingHorizon {
        let startDate = calendar.startOfDay(for: today)
        let weekday = calendar.component(.weekday, from: startDate)
        let daysUntilSunday = (8 - weekday) % 7
        let days = (0 ... daysUntilSunday).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDate)
        }
        let endDate = days.last ?? startDate

        return SchedulingHorizon(
            startDate: startDate,
            endDate: endDate,
            days: days
        )
    }

    func makeMutation(input: SchedulingInput) -> ScheduleMutation {
        let horizon = makeHorizon(today: input.today, calendar: input.calendar)
        let analysis = occurrenceAnalyzer.analyze(
            scheduledTasks: input.scheduledTasks,
            horizon: horizon
        )
        let urgentCandidates = candidateGenerator.makeUrgentCandidates(
            tasks: input.tasks,
            analysis: analysis,
            horizon: horizon
        )
        let regularCandidates = candidateGenerator.makeRegularCandidates(
            input: input,
            horizon: horizon,
            analysis: analysis,
            urgentCandidates: urgentCandidates,
            recurrenceCalculator: recurrenceCalculator
        )
        let allocation = candidateAllocator.allocate(
            candidates: urgentCandidates + regularCandidates,
            tasks: input.tasks,
            horizon: horizon,
            preservedOccurrences: analysis.preservedOccurrences,
            dailyLimit: input.dailyLimit,
            calendar: input.calendar
        )
        let occurrencesByID = Dictionary(
            uniqueKeysWithValues: input.scheduledTasks.map { ($0.id, $0) }
        )

        return ScheduleMutation(
            occurrencesToCreate: allocation.allocations.map {
                makePlannedOccurrence(
                    from: $0.candidate,
                    scheduledDate: $0.scheduledDate,
                    now: input.today
                )
            } + allocation.unplacedCandidates.compactMap {
                makePostponedOccurrence(from: $0, now: input.today)
            },
            occurrencesToUpdate: occurrenceUpdates(
                for: allocation.allocations + allocation.unplacedCandidates.map {
                    ScheduledCandidateAllocation(candidate: $0, scheduledDate: horizon.endDate)
                },
                occurrencesByID: occurrencesByID,
                now: input.today
            )
        )
    }

    // MARK: - Private

    private func makePlannedOccurrence(
        from candidate: SchedulingCandidate,
        scheduledDate: Date,
        now: Date
    ) -> ScheduledTask {
        ScheduledTask(
            taskId: candidate.task.id,
            scheduledDate: scheduledDate,
            originalScheduledDate: candidate.originalScheduledDate ?? scheduledDate,
            sourceOccurrenceId: candidate.sourceOccurrenceId,
            createdAt: now,
            updatedAt: now
        )
    }

    private func makePostponedOccurrence(
        from candidate: SchedulingCandidate,
        now: Date
    ) -> ScheduledTask? {
        guard candidate.sourceOccurrenceId == nil else {
            return nil
        }

        return ScheduledTask(
            taskId: candidate.task.id,
            scheduledDate: now,
            status: .postponed,
            createdAt: now,
            updatedAt: now
        )
    }

    private func occurrenceUpdates(
        for allocations: [ScheduledCandidateAllocation],
        occurrencesByID: [UUID: ScheduledTask],
        now: Date
    ) -> [ScheduledTask] {
        allocations.compactMap { allocation in
            guard let sourceOccurrenceID = allocation.candidate.sourceOccurrenceId,
                  var sourceOccurrence = occurrencesByID[sourceOccurrenceID],
                  sourceOccurrence.status != .postponed
            else {
                return nil
            }

            sourceOccurrence.status = .postponed
            sourceOccurrence.updatedAt = now
            return sourceOccurrence
        }
    }
}
