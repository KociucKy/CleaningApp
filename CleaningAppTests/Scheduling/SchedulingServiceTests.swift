import Foundation
import Testing
@testable import CleaningApp

// MARK: - SchedulingServiceTests

@Suite(.tags(.home))
@MainActor
struct SchedulingServiceTests {
    // MARK: - Properties

    private let service = SchedulingService()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    // MARK: - Horizon

    @Test func makeHorizon_fromMonday_includesSevenCalendarDays() throws {
        let today = try makeDate(year: 2026, month: 10, day: 19, hour: 14)
        let expectedStartDate = try makeDate(year: 2026, month: 10, day: 19)
        let expectedEndDate = try makeDate(year: 2026, month: 10, day: 25)

        let horizon = service.makeHorizon(today: today, calendar: calendar)

        #expect(horizon.startDate == expectedStartDate)
        #expect(horizon.endDate == expectedEndDate)
        #expect(horizon.days.count == 7)
    }

    @Test func makeHorizon_fromWednesday_includesRemainingWeekDays() throws {
        let today = try makeDate(year: 2026, month: 10, day: 21, hour: 9)
        let expectedStartDate = try makeDate(year: 2026, month: 10, day: 21)
        let expectedEndDate = try makeDate(year: 2026, month: 10, day: 25)

        let horizon = service.makeHorizon(today: today, calendar: calendar)

        #expect(horizon.startDate == expectedStartDate)
        #expect(horizon.endDate == expectedEndDate)
        #expect(horizon.days.count == 5)
    }

    @Test func makeHorizon_fromSunday_includesOnlyToday() throws {
        let today = try makeDate(year: 2026, month: 10, day: 25, hour: 20)
        let expectedDate = try makeDate(year: 2026, month: 10, day: 25)

        let horizon = service.makeHorizon(today: today, calendar: calendar)

        #expect(horizon.startDate == expectedDate)
        #expect(horizon.endDate == expectedDate)
        #expect(horizon.days.count == 1)
    }

    // MARK: - Mutation

    @Test func makeMutation_preservesCurrentWeekAssignments() throws {
        let today = try makeDate(year: 2026, month: 10, day: 25)
        let task = try makeTask(name: "Daily", frequency: .daily)
        let preservedOccurrence = ScheduledTask(
            taskId: task.id,
            scheduledDate: today,
            createdAt: today,
            updatedAt: today
        )

        let mutation = service.makeMutation(
            input: makeInput(
                tasks: [task],
                scheduledTasks: [preservedOccurrence],
                today: today
            )
        )

        #expect(mutation.occurrencesToCreate.isEmpty)
        #expect(mutation.occurrencesToUpdate.isEmpty)
    }

    @Test func makeMutation_createsPlannedOccurrenceForAllocatedRegularWork() throws {
        let today = try makeDate(year: 2026, month: 10, day: 25)
        let task = try makeTask(name: "Daily", frequency: .daily)

        let mutation = service.makeMutation(
            input: makeInput(tasks: [task], today: today)
        )

        #expect(mutation.occurrencesToCreate.count == 1)
        #expect(mutation.occurrencesToCreate.first?.taskId == task.id)
        #expect(mutation.occurrencesToCreate.first?.status == .planned)
        #expect(mutation.occurrencesToCreate.first?.scheduledDate == today)
    }

    @Test func makeMutation_carriesOverdueOccurrenceIntoSuccessorChain() throws {
        let today = try makeDate(year: 2026, month: 10, day: 25)
        let overdueDate = try makeDate(year: 2026, month: 10, day: 24)
        let task = try makeTask(name: "Daily", frequency: .daily)
        let overdueOccurrence = ScheduledTask(
            taskId: task.id,
            scheduledDate: overdueDate,
            createdAt: overdueDate,
            updatedAt: overdueDate
        )

        let mutation = service.makeMutation(
            input: makeInput(
                tasks: [task],
                scheduledTasks: [overdueOccurrence],
                today: today
            )
        )

        #expect(mutation.occurrencesToCreate.count == 1)
        #expect(mutation.occurrencesToCreate.first?.sourceOccurrenceId == overdueOccurrence.id)
        #expect(mutation.occurrencesToUpdate == [
            ScheduledTask(
                id: overdueOccurrence.id,
                taskId: overdueOccurrence.taskId,
                scheduledDate: overdueOccurrence.scheduledDate,
                originalScheduledDate: overdueOccurrence.originalScheduledDate,
                status: .postponed,
                sourceOccurrenceId: overdueOccurrence.sourceOccurrenceId,
                createdAt: overdueOccurrence.createdAt,
                updatedAt: today
            ),
        ])
    }

    @Test func makeMutation_turnsUnplaceableRegularWorkIntoBacklog() throws {
        let today = try makeDate(year: 2026, month: 10, day: 25)
        let blockerTask = try makeTask(name: "Blocker", frequency: .weekly)
        let task = try makeTask(name: "Daily", frequency: .daily)
        let preservedOccurrence = ScheduledTask(
            taskId: blockerTask.id,
            scheduledDate: today,
            createdAt: today,
            updatedAt: today
        )

        let mutation = service.makeMutation(
            input: makeInput(
                tasks: [blockerTask, task],
                scheduledTasks: [preservedOccurrence],
                today: today,
                dailyLimit: 10
            )
        )

        #expect(mutation.occurrencesToCreate.count == 1)
        #expect(mutation.occurrencesToCreate.first?.taskId == task.id)
        #expect(mutation.occurrencesToCreate.first?.status == .postponed)
    }

    // MARK: - Private

    private func makeInput(
        tasks: [RoomTask],
        scheduledTasks: [ScheduledTask] = [],
        today: Date,
        dailyLimit: Int = 30
    ) -> SchedulingInput {
        SchedulingInput(
            tasks: tasks,
            scheduledTasks: scheduledTasks,
            completedTasks: [],
            skippedTasks: [],
            today: today,
            dailyLimit: dailyLimit,
            calendar: calendar
        )
    }

    private func makeTask(name: String, frequency: Frequency) throws -> RoomTask {
        RoomTask(
            name: name,
            roomId: UUID(),
            frequency: frequency,
            estimatedDuration: .fifteenMinutes,
            createdAt: try makeDate(year: 2026, month: 10, day: 1)
        )
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0
    ) throws -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: year,
            month: month,
            day: day,
            hour: hour
        )
        return try #require(calendar.date(from: components))
    }
}
