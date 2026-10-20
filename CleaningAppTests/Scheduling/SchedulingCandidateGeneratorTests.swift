import Foundation
import Testing
@testable import CleaningApp

// MARK: - SchedulingCandidateGeneratorTests

@Suite(.tags(.home))
@MainActor
struct SchedulingCandidateGeneratorTests {
    // MARK: - Properties

    private let generator = SchedulingCandidateGenerator()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    // MARK: - Urgent Candidates

    @Test func makeUrgentCandidates_prioritizesBacklogBeforeOverdueWork() throws {
        let horizon = try makeHorizon()
        let backlogTask = try makeTask(name: "Backlog")
        let overdueTask = try makeTask(name: "Overdue")
        let backlog = try makeOccurrence(task: backlogTask, day: 17, status: .postponed)
        let overdue = try makeOccurrence(task: overdueTask, day: 18)

        let candidates = generator.makeUrgentCandidates(
            tasks: [backlogTask, overdueTask],
            analysis: SchedulingOccurrenceAnalysis(
                preservedOccurrences: [],
                overdueOccurrences: [overdue],
                backlogOccurrences: [backlog]
            ),
            horizon: horizon
        )

        #expect(candidates.map(\.kind) == [.backlog, .overdue])
        #expect(candidates.map(\.task.id) == [backlogTask.id, overdueTask.id])
    }

    @Test func makeUrgentCandidates_suppressesOverdueDuplicateWhenBacklogExists() throws {
        let horizon = try makeHorizon()
        let task = try makeTask(name: "Kitchen")
        let backlog = try makeOccurrence(task: task, day: 17, status: .postponed)
        let overdue = try makeOccurrence(task: task, day: 18)

        let candidates = generator.makeUrgentCandidates(
            tasks: [task],
            analysis: SchedulingOccurrenceAnalysis(
                preservedOccurrences: [],
                overdueOccurrences: [overdue],
                backlogOccurrences: [backlog]
            ),
            horizon: horizon
        )

        #expect(candidates.count == 1)
        #expect(candidates.first?.kind == .backlog)
        #expect(candidates.first?.sourceOccurrenceId == backlog.id)
    }

    @Test func makeUrgentCandidates_usesLearnedDurationWhenAvailable() throws {
        let horizon = try makeHorizon()
        let task = try makeTask(name: "Bathroom", learnedDuration: 22)
        let overdue = try makeOccurrence(task: task, day: 18)

        let candidates = generator.makeUrgentCandidates(
            tasks: [task],
            analysis: SchedulingOccurrenceAnalysis(
                preservedOccurrences: [],
                overdueOccurrences: [overdue],
                backlogOccurrences: []
            ),
            horizon: horizon
        )

        #expect(candidates.first?.effectiveDuration == 22)
    }

    @Test func makeUrgentCandidates_ignoresOccurrencesForDeletedTasks() throws {
        let horizon = try makeHorizon()
        let deletedTask = try makeTask(name: "Deleted")
        let overdue = try makeOccurrence(task: deletedTask, day: 18)

        let candidates = generator.makeUrgentCandidates(
            tasks: [],
            analysis: SchedulingOccurrenceAnalysis(
                preservedOccurrences: [],
                overdueOccurrences: [overdue],
                backlogOccurrences: []
            ),
            horizon: horizon
        )

        #expect(candidates.isEmpty)
    }

    // MARK: - Private

    private func makeHorizon() throws -> SchedulingHorizon {
        let startDate = try makeDate(day: 19)
        let endDate = try makeDate(day: 25)
        let days = try (19 ... 25).map { try makeDate(day: $0) }

        return SchedulingHorizon(
            startDate: startDate,
            endDate: endDate,
            days: days
        )
    }

    private func makeTask(
        name: String,
        learnedDuration: Int? = nil
    ) throws -> RoomTask {
        RoomTask(
            name: name,
            roomId: UUID(),
            frequency: .timesPerWeek(1),
            estimatedDuration: .fifteenMinutes,
            learnedDuration: learnedDuration,
            createdAt: try makeDate(day: 19)
        )
    }

    private func makeOccurrence(
        task: RoomTask,
        day: Int,
        status: ScheduledTaskStatus = .planned
    ) throws -> ScheduledTask {
        ScheduledTask(
            taskId: task.id,
            scheduledDate: try makeDate(day: day),
            status: status
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
}
