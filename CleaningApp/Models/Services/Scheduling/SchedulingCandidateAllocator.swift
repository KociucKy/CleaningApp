import Foundation

// MARK: - SchedulingCandidateAllocator

@MainActor
final class SchedulingCandidateAllocator {
    // MARK: - Methods

    func allocate(
        candidates: [SchedulingCandidate],
        tasks: [RoomTask],
        horizon: SchedulingHorizon,
        preservedOccurrences: [ScheduledTask],
        dailyLimit: Int,
        calendar: Calendar
    ) -> SchedulingAllocationResult {
        var dayStates = makeDayStates(
            days: horizon.days,
            preservedOccurrences: preservedOccurrences,
            tasks: tasks,
            dailyLimit: dailyLimit,
            calendar: calendar
        )
        let sortedCandidates = candidates.sorted {
            isOrderedBefore(
                $0,
                than: $1,
                horizon: horizon,
                dailyLimit: dailyLimit,
                dayStates: dayStates,
                calendar: calendar
            )
        }
        var allocations: [ScheduledCandidateAllocation] = []
        var unplacedCandidates: [SchedulingCandidate] = []

        for candidate in sortedCandidates {
            guard let date = firstEligibleDate(
                for: candidate,
                horizon: horizon,
                dailyLimit: dailyLimit,
                dayStates: dayStates,
                calendar: calendar
            ), let index = dayStates.firstIndex(where: { $0.date == date })
            else {
                unplacedCandidates.append(candidate)
                continue
            }

            dayStates[index].add(
                taskID: candidate.task.id,
                duration: candidate.effectiveDuration,
                dailyLimit: dailyLimit
            )
            allocations.append(
                ScheduledCandidateAllocation(
                    candidate: candidate,
                    scheduledDate: date
                )
            )
        }

        return SchedulingAllocationResult(
            allocations: allocations,
            unplacedCandidates: unplacedCandidates
        )
    }

    // MARK: - Private

    private func makeDayStates(
        days: [Date],
        preservedOccurrences: [ScheduledTask],
        tasks: [RoomTask],
        dailyLimit: Int,
        calendar: Calendar
    ) -> [DayState] {
        let durationsByTaskID = Dictionary(
            uniqueKeysWithValues: tasks.map {
                ($0.id, $0.learnedDuration ?? $0.estimatedDuration.rawValue)
            }
        )

        return days.map { day in
            let occurrences = preservedOccurrences.filter {
                calendar.isDate($0.scheduledDate, inSameDayAs: day) && $0.status == .planned
            }
            let load = occurrences.reduce(into: 0) { result, occurrence in
                result += durationsByTaskID[occurrence.taskId] ?? 0
            }

            return DayState(
                date: day,
                load: load,
                taskIDs: Set(occurrences.map(\.taskId)),
                isExclusive: occurrences.contains {
                    (durationsByTaskID[$0.taskId] ?? 0) > dailyLimit
                }
            )
        }
    }

    private func isOrderedBefore(
        _ first: SchedulingCandidate,
        than second: SchedulingCandidate,
        horizon: SchedulingHorizon,
        dailyLimit: Int,
        dayStates: [DayState],
        calendar: Calendar
    ) -> Bool {
        let firstEligibleDayCount = horizon.days.filter {
            isEligible(
                first,
                for: $0,
                dailyLimit: dailyLimit,
                dayStates: dayStates,
                calendar: calendar
            )
        }.count
        let secondEligibleDayCount = horizon.days.filter {
            isEligible(
                second,
                for: $0,
                dailyLimit: dailyLimit,
                dayStates: dayStates,
                calendar: calendar
            )
        }.count

        if priority(for: first.kind) != priority(for: second.kind) {
            return priority(for: first.kind) < priority(for: second.kind)
        }
        if first.effectiveDuration != second.effectiveDuration {
            return first.effectiveDuration > second.effectiveDuration
        }
        if firstEligibleDayCount != secondEligibleDayCount {
            return firstEligibleDayCount < secondEligibleDayCount
        }
        return first.id.uuidString < second.id.uuidString
    }

    private func priority(for kind: SchedulingCandidateKind) -> Int {
        switch kind {
        case .backlog:
            return 0
        case .overdue:
            return 1
        case .regular:
            return 2
        }
    }

    private func firstEligibleDate(
        for candidate: SchedulingCandidate,
        horizon: SchedulingHorizon,
        dailyLimit: Int,
        dayStates: [DayState],
        calendar: Calendar
    ) -> Date? {
        horizon.days.first { day in
            isEligible(
                candidate,
                for: day,
                dailyLimit: dailyLimit,
                dayStates: dayStates,
                calendar: calendar
            )
        }
    }

    private func isEligible(
        _ candidate: SchedulingCandidate,
        for day: Date,
        dailyLimit: Int,
        dayStates: [DayState],
        calendar: Calendar
    ) -> Bool {
        guard day >= calendar.startOfDay(for: candidate.earliestDate),
              let dayState = dayStates.first(where: { $0.date == day }),
              !dayState.taskIDs.contains(candidate.task.id),
              !dayState.isExclusive
        else {
            return false
        }

        if candidate.effectiveDuration > dailyLimit {
            return dayState.load == 0
        }

        return dayState.load + candidate.effectiveDuration <= dailyLimit + 2
    }
}

// MARK: - DayState

private struct DayState {
    // MARK: - Properties

    let date: Date
    private(set) var load: Int
    private(set) var taskIDs: Set<UUID>
    private(set) var isExclusive: Bool

    // MARK: - Methods

    mutating func add(taskID: UUID, duration: Int, dailyLimit: Int) {
        load += duration
        taskIDs.insert(taskID)
        isExclusive = duration > dailyLimit
    }
}
