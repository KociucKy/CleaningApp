import Foundation
import Testing
@testable import CleaningApp

// MARK: - ScheduledTaskManagerTests

@Suite(.tags(.home))
@MainActor
struct ScheduledTaskManagerTests {
    // MARK: - Tests

    @Test func fetchActiveOccurrences_excludesFinishedStates() throws {
        let taskID = UUID()
        let date = try makeDate()
        let planned = ScheduledTask(taskId: taskID, scheduledDate: date)
        let postponed = ScheduledTask(taskId: taskID, scheduledDate: date, status: .postponed)
        let completed = ScheduledTask(taskId: taskID, scheduledDate: date, status: .completed)
        let manager = ScheduledTaskManager(repository: MockScheduledTaskRepository())
        try manager.save(planned)
        try manager.save(postponed)
        try manager.save(completed)

        let activeOccurrences = try manager.fetchActiveOccurrences(for: taskID)

        #expect(Set(activeOccurrences.map(\.id)) == [planned.id, postponed.id])
    }

    @Test func fetchSuccessors_returnsOnlyLinkedOccurrences() throws {
        let date = try makeDate()
        let sourceID = UUID()
        let successor = ScheduledTask(
            taskId: UUID(),
            scheduledDate: date,
            sourceOccurrenceId: sourceID
        )
        let unrelated = ScheduledTask(taskId: UUID(), scheduledDate: date)
        let manager = ScheduledTaskManager(repository: MockScheduledTaskRepository())
        try manager.save(successor)
        try manager.save(unrelated)

        let successors = try manager.fetchSuccessors(for: sourceID)

        #expect(successors.map(\.id) == [successor.id])
    }

    // MARK: - Private

    private func makeDate() throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let components = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026,
            month: 10,
            day: 25
        )
        return try #require(calendar.date(from: components))
    }
}
