import Foundation
import Testing
@testable import CleaningApp

// MARK: - SchedulePresenterTests

@Suite(.tags(.home))
@MainActor
struct SchedulePresenterTests {
    // MARK: - Properties

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    // MARK: - Tests

    @Test func ensureSchedule_preservesAnActivePlan() throws {
        let today = try makeDate(day: 25)
        let interactor = TestInteractor(
            scheduledTasks: [ScheduledTask(taskId: UUID(), scheduledDate: today)]
        )
        let presenter = SchedulePresenter(interactor: interactor, router: TestRouter())

        presenter.ensureSchedule(today: today, calendar: calendar)

        #expect(interactor.endDayCalls.isEmpty)
        #expect(interactor.refreshCalls.isEmpty)
    }

    @Test func ensureSchedule_closesElapsedDayBeforeKeepingTodayPlan() throws {
        let yesterday = try makeDate(day: 24)
        let today = try makeDate(day: 25)
        let interactor = TestInteractor(
            scheduledTasks: [
                ScheduledTask(taskId: UUID(), scheduledDate: yesterday),
                ScheduledTask(taskId: UUID(), scheduledDate: today)
            ]
        )
        let presenter = SchedulePresenter(interactor: interactor, router: TestRouter())

        presenter.ensureSchedule(today: today, calendar: calendar)

        #expect(interactor.endDayCalls == [yesterday])
        #expect(interactor.refreshCalls.isEmpty)
    }

    @Test func ensureSchedule_refreshesWhenThereIsNoActivePlan() throws {
        let today = try makeDate(day: 25)
        let interactor = TestInteractor()
        let presenter = SchedulePresenter(interactor: interactor, router: TestRouter())

        presenter.ensureSchedule(today: today, calendar: calendar)

        #expect(interactor.endDayCalls.isEmpty)
        #expect(interactor.refreshCalls == [today])
    }

    // MARK: - Private

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

    // MARK: - Test Doubles

    private final class TestInteractor: ScheduleInteractor {
        private let scheduledTasks: [ScheduledTask]
        private(set) var endDayCalls: [Date] = []
        private(set) var refreshCalls: [Date] = []

        init(scheduledTasks: [ScheduledTask] = []) {
            self.scheduledTasks = scheduledTasks
        }

        func fetchAllRooms() throws -> [Room] {
            []
        }

        func fetchAllRoomTasks() throws -> [RoomTask] {
            []
        }

        func fetchAllScheduledTasks() throws -> [ScheduledTask] {
            scheduledTasks
        }

        func completeScheduledTask(id: UUID, completedAt: Date, measuredDuration: Int?) throws {}

        func skipScheduledTask(id: UUID, skippedAt: Date, dailyLimit: Int) throws -> ScheduleMutation {
            ScheduleMutation()
        }

        func undoSkipScheduledTask(id: UUID, restoredAt: Date) throws {}

        func endScheduleDay(endedAt: Date, dailyLimit: Int) throws -> ScheduleMutation {
            endDayCalls.append(endedAt)
            return ScheduleMutation()
        }

        func refreshSchedule(today: Date, dailyLimit: Int) throws -> ScheduleMutation {
            refreshCalls.append(today)
            return ScheduleMutation()
        }

        func dailyScheduleLimit() -> Int {
            30
        }
    }

    private final class TestRouter: ScheduleRouter {}
}
