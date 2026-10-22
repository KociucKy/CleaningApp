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

    @Test func makeHorizon_crossesYearBoundary() throws {
        let today = try makeDate(year: 2026, month: 12, day: 31, hour: 14)
        let expectedStartDate = try makeDate(year: 2026, month: 12, day: 31)
        let expectedEndDate = try makeDate(year: 2027, month: 1, day: 3)

        let horizon = service.makeHorizon(today: today, calendar: calendar)

        #expect(horizon.startDate == expectedStartDate)
        #expect(horizon.endDate == expectedEndDate)
        #expect(horizon.days.count == 4)
    }

    @Test func makeHorizon_preservesCalendarDaysAcrossDaylightSavingTime() throws {
        var pacificCalendar = Calendar(identifier: .gregorian)
        pacificCalendar.timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
        let today = try makeDate(
            calendar: pacificCalendar,
            year: 2026,
            month: 3,
            day: 7,
            hour: 14
        )
        let expectedStartDate = try makeDate(
            calendar: pacificCalendar,
            year: 2026,
            month: 3,
            day: 7
        )
        let expectedEndDate = try makeDate(
            calendar: pacificCalendar,
            year: 2026,
            month: 3,
            day: 8
        )

        let horizon = service.makeHorizon(today: today, calendar: pacificCalendar)

        #expect(horizon.startDate == expectedStartDate)
        #expect(horizon.endDate == expectedEndDate)
        #expect(horizon.days.count == 2)
    }

    @Test func makeHorizon_normalizesToProvidedCalendarTimeZone() throws {
        var warsawCalendar = Calendar(identifier: .gregorian)
        warsawCalendar.timeZone = try #require(TimeZone(identifier: "Europe/Warsaw"))
        let today = try makeDate(
            calendar: warsawCalendar,
            year: 2026,
            month: 10,
            day: 21,
            hour: 23
        )
        let expectedStartDate = try makeDate(
            calendar: warsawCalendar,
            year: 2026,
            month: 10,
            day: 21
        )

        let horizon = service.makeHorizon(today: today, calendar: warsawCalendar)

        #expect(horizon.startDate == expectedStartDate)
        #expect(warsawCalendar.component(.day, from: horizon.endDate) == 25)
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

    @Test func makeMutation_returnsUnplaceableRegularWorkToGeneralPool() throws {
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

        #expect(mutation.occurrencesToCreate.isEmpty)
        #expect(mutation.occurrencesToUpdate.isEmpty)
    }

    @Test func makeMutation_onThursdayDoesNotCreateBacklogForInitialSetupOverflow() throws {
        let today = try makeDate(year: 2026, month: 10, day: 22)
        let tasks = try (1 ... 30).map { index in
            try makeTask(name: "Task \(index)", frequency: .weekly)
        }

        let mutation = service.makeMutation(
            input: makeInput(
                tasks: tasks,
                today: today,
                dailyLimit: 30
            )
        )

        #expect(mutation.occurrencesToCreate.allSatisfy { $0.status == .planned })
        #expect(mutation.occurrencesToCreate.count < tasks.count)
        #expect(mutation.occurrencesToUpdate.isEmpty)
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

    private func makeDate(
        calendar: Calendar,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0
    ) throws -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour
        )
        return try #require(calendar.date(from: components))
    }
}
