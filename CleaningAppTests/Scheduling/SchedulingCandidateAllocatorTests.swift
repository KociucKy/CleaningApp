import Foundation
import Testing
@testable import CleaningApp

// MARK: - SchedulingCandidateAllocatorTests

@Suite(.tags(.home))
@MainActor
struct SchedulingCandidateAllocatorTests {
    // MARK: - Properties

    private let allocator = SchedulingCandidateAllocator()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    // MARK: - Tests

    @Test func allocate_placesUrgentWorkBeforeRegularWork() throws {
        let horizon = try makeHorizon(days: 19 ... 20)
        let backlogTask = try makeTask(name: "Backlog", duration: .fifteenMinutes)
        let regularTask = try makeTask(name: "Regular", duration: .fifteenMinutes)
        let candidates = [
            SchedulingCandidate(
                task: regularTask,
                kind: .regular,
                earliestDate: horizon.startDate
            ),
            SchedulingCandidate(
                task: backlogTask,
                kind: .backlog,
                earliestDate: horizon.startDate
            ),
        ]

        let result = allocator.allocate(
            candidates: candidates,
            tasks: [backlogTask, regularTask],
            horizon: horizon,
            preservedOccurrences: [],
            dailyLimit: 30,
            calendar: calendar
        )

        #expect(result.allocations.map(\.candidate.task.id) == [backlogTask.id, regularTask.id])
    }

    @Test func allocate_allowsTwoMinuteTolerance() throws {
        let horizon = try makeHorizon(days: 19 ... 19)
        let firstTask = try makeTask(name: "First", duration: .fifteenMinutes)
        let secondTask = try makeTask(name: "Second", duration: .fifteenMinutes)
        let twoMinuteTask = try makeTask(name: "Two", duration: .fiveMinutes, learnedDuration: 2)
        let candidates = [firstTask, secondTask, twoMinuteTask].map {
            SchedulingCandidate(task: $0, kind: .regular, earliestDate: horizon.startDate)
        }

        let result = allocator.allocate(
            candidates: candidates,
            tasks: [firstTask, secondTask, twoMinuteTask],
            horizon: horizon,
            preservedOccurrences: [],
            dailyLimit: 30,
            calendar: calendar
        )

        #expect(result.allocations.count == 3)
        #expect(result.unplacedCandidates.isEmpty)
    }

    @Test func allocate_keepsLongTaskAloneOnEmptyDay() throws {
        let horizon = try makeHorizon(days: 19 ... 20)
        let longTask = try makeTask(name: "Long", duration: .fifteenMinutes, learnedDuration: 45)
        let regularTask = try makeTask(name: "Regular", duration: .fifteenMinutes)
        let candidates = [
            SchedulingCandidate(task: regularTask, kind: .regular, earliestDate: horizon.startDate),
            SchedulingCandidate(task: longTask, kind: .regular, earliestDate: horizon.startDate),
        ]

        let result = allocator.allocate(
            candidates: candidates,
            tasks: [longTask, regularTask],
            horizon: horizon,
            preservedOccurrences: [],
            dailyLimit: 30,
            calendar: calendar
        )

        #expect(result.allocations.count == 2)
        #expect(result.allocations.first(where: { $0.candidate.task.id == longTask.id })?.scheduledDate == horizon.startDate)
        #expect(result.allocations.first(where: { $0.candidate.task.id == regularTask.id })?.scheduledDate != horizon.startDate)
    }

    @Test func allocate_doesNotScheduleTaskMoreThanOncePerDay() throws {
        let horizon = try makeHorizon(days: 19 ... 19)
        let task = try makeTask(name: "Daily", duration: .fifteenMinutes)
        let candidates = [
            SchedulingCandidate(task: task, kind: .regular, earliestDate: horizon.startDate),
            SchedulingCandidate(task: task, kind: .regular, earliestDate: horizon.startDate),
        ]

        let result = allocator.allocate(
            candidates: candidates,
            tasks: [task],
            horizon: horizon,
            preservedOccurrences: [],
            dailyLimit: 30,
            calendar: calendar
        )

        #expect(result.allocations.count == 1)
        #expect(result.unplacedCandidates.count == 1)
    }

    @Test func allocate_placesUrgentCandidateOnEarliestEligibleDay() throws {
        let horizon = try makeHorizon(days: 19 ... 20)
        let preservedTask = try makeTask(name: "Preserved", duration: .fifteenMinutes)
        let backlogTask = try makeTask(name: "Backlog", duration: .fifteenMinutes)
        let preservedOccurrence = try makeOccurrence(task: preservedTask, day: 19)
        let backlogCandidate = SchedulingCandidate(
            task: backlogTask,
            kind: .backlog,
            earliestDate: horizon.startDate
        )

        let result = allocator.allocate(
            candidates: [backlogCandidate],
            tasks: [preservedTask, backlogTask],
            horizon: horizon,
            preservedOccurrences: [preservedOccurrence],
            dailyLimit: 30,
            calendar: calendar
        )

        #expect(result.allocations.first?.scheduledDate == horizon.startDate)
    }

    @Test func allocate_spreadsRegularOccurrencesForTheSameTask() throws {
        let horizon = try makeHorizon(days: 19 ... 23)
        let task = try makeTask(name: "Twice Weekly", duration: .fifteenMinutes)
        let candidates = [
            SchedulingCandidate(task: task, kind: .regular, earliestDate: horizon.startDate),
            SchedulingCandidate(task: task, kind: .regular, earliestDate: horizon.startDate),
        ]

        let result = allocator.allocate(
            candidates: candidates,
            tasks: [task],
            horizon: horizon,
            preservedOccurrences: [],
            dailyLimit: 30,
            calendar: calendar
        )

        #expect(Set(result.allocations.map(\.scheduledDate)) == [horizon.startDate, horizon.endDate])
    }

    @Test func allocate_balancesRegularLoadAfterSpacingTie() throws {
        let horizon = try makeHorizon(days: 19 ... 21)
        let preservedTask = try makeTask(name: "Preserved", duration: .fifteenMinutes)
        let regularTask = try makeTask(name: "Regular", duration: .fifteenMinutes)
        let preservedOccurrence = try makeOccurrence(task: preservedTask, day: 19)
        let regularCandidate = SchedulingCandidate(
            task: regularTask,
            kind: .regular,
            earliestDate: horizon.startDate
        )
        let expectedDate = try makeDate(day: 20)

        let result = allocator.allocate(
            candidates: [regularCandidate],
            tasks: [preservedTask, regularTask],
            horizon: horizon,
            preservedOccurrences: [preservedOccurrence],
            dailyLimit: 30,
            calendar: calendar
        )

        #expect(result.allocations.first?.scheduledDate == expectedDate)
    }

    // MARK: - Private

    private func makeHorizon(days: ClosedRange<Int>) throws -> SchedulingHorizon {
        let dates = try days.map { try makeDate(day: $0) }
        let startDate = try #require(dates.first)
        let endDate = try #require(dates.last)

        return SchedulingHorizon(startDate: startDate, endDate: endDate, days: dates)
    }

    private func makeTask(
        name: String,
        duration: TaskDuration,
        learnedDuration: Int? = nil
    ) throws -> RoomTask {
        RoomTask(
            name: name,
            roomId: UUID(),
            frequency: .weekly,
            estimatedDuration: duration,
            learnedDuration: learnedDuration,
            createdAt: try makeDate(day: 1)
        )
    }

    private func makeDate(day: Int) throws -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026,
            month: 10,
            day: day
        )
        return try #require(calendar.date(from: components))
    }

    private func makeOccurrence(task: RoomTask, day: Int) throws -> ScheduledTask {
        ScheduledTask(taskId: task.id, scheduledDate: try makeDate(day: day))
    }
}
