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

    // MARK: - Private

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
