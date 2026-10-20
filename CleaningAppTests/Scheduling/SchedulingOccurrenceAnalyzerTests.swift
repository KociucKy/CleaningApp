import Foundation
import Testing
@testable import CleaningApp

// MARK: - SchedulingOccurrenceAnalyzerTests

@Suite(.tags(.home))
@MainActor
struct SchedulingOccurrenceAnalyzerTests {
    // MARK: - Properties

    private let analyzer = SchedulingOccurrenceAnalyzer()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    // MARK: - Analysis

    @Test func analyze_preservesPlannedOccurrencesInHorizon() throws {
        let horizon = try makeHorizon()
        let todayOccurrence = try makeOccurrence(day: 19)
        let fridayOccurrence = try makeOccurrence(day: 23)

        let analysis = analyzer.analyze(
            scheduledTasks: [fridayOccurrence, todayOccurrence],
            horizon: horizon
        )

        #expect(analysis.preservedOccurrences == [todayOccurrence, fridayOccurrence])
        #expect(analysis.overdueOccurrences.isEmpty)
        #expect(analysis.backlogOccurrences.isEmpty)
    }

    @Test func analyze_identifiesIncompletePastOccurrenceAsOverdue() throws {
        let horizon = try makeHorizon()
        let overdueOccurrence = try makeOccurrence(day: 18)

        let analysis = analyzer.analyze(
            scheduledTasks: [overdueOccurrence],
            horizon: horizon
        )

        #expect(analysis.preservedOccurrences.isEmpty)
        #expect(analysis.overdueOccurrences == [overdueOccurrence])
    }

    @Test func analyze_identifiesPostponedOccurrenceAsBacklog() throws {
        let horizon = try makeHorizon()
        let backlogOccurrence = try makeOccurrence(day: 18, status: .postponed)

        let analysis = analyzer.analyze(
            scheduledTasks: [backlogOccurrence],
            horizon: horizon
        )

        #expect(analysis.backlogOccurrences == [backlogOccurrence])
        #expect(analysis.preservedOccurrences.isEmpty)
        #expect(analysis.overdueOccurrences.isEmpty)
    }

    @Test func analyze_ignoresTerminalOccurrences() throws {
        let horizon = try makeHorizon()
        let completedOccurrence = try makeOccurrence(day: 19, status: .completed)
        let skippedOccurrence = try makeOccurrence(day: 19, status: .skipped)
        let cancelledOccurrence = try makeOccurrence(day: 19, status: .cancelled)

        let analysis = analyzer.analyze(
            scheduledTasks: [completedOccurrence, skippedOccurrence, cancelledOccurrence],
            horizon: horizon
        )

        #expect(analysis.preservedOccurrences.isEmpty)
        #expect(analysis.overdueOccurrences.isEmpty)
        #expect(analysis.backlogOccurrences.isEmpty)
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

    private func makeOccurrence(
        day: Int,
        status: ScheduledTaskStatus = .planned
    ) throws -> ScheduledTask {
        let date = try makeDate(day: day)
        return ScheduledTask(
            taskId: UUID(),
            scheduledDate: date,
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
