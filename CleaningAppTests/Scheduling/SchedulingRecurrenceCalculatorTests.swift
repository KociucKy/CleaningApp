import Testing
@testable import CleaningApp

// MARK: - SchedulingRecurrenceCalculatorTests

@Suite(.tags(.home))
@MainActor
struct SchedulingRecurrenceCalculatorTests {
    // MARK: - Properties

    private let calculator = SchedulingRecurrenceCalculator()

    // MARK: - Rules

    @Test(arguments: [
        (Frequency.daily, SchedulingFrequencyRule.intervalDays(1)),
        (.everyOtherDay, .intervalDays(2)),
        (.everyXDays(4), .intervalDays(4)),
        (.timesPerWeek(3), .weeklyQuota(3)),
        (.everyOtherWeek, .intervalWeeks(2)),
        (.everyXWeeks(3), .intervalWeeks(3)),
        (.monthly, .monthlyQuota(1)),
        (.timesPerMonth(2), .monthlyQuota(2)),
        (.quarterly, .intervalMonths(3)),
        (.biannually, .intervalMonths(6)),
        (.yearly, .intervalMonths(12))
    ])
    func rule_canonicalizesFrequency(
        frequency: Frequency,
        expectedRule: SchedulingFrequencyRule
    ) {
        #expect(calculator.rule(for: frequency) == expectedRule)
    }

    @Test func rule_clampsInvalidIntervalValues() {
        #expect(calculator.rule(for: .everyXDays(0)) == .intervalDays(1))
        #expect(calculator.rule(for: .everyXWeeks(0)) == .intervalWeeks(1))
        #expect(calculator.rule(for: .everyXMonths(0)) == .intervalMonths(1))
    }

    // MARK: - Quota

    @Test func proRatedQuota_forWednesdayWeeklyTask_returnsTwoOccurrences() {
        let quota = calculator.proRatedQuota(
            totalOccurrences: 3,
            activeDays: 5,
            periodDays: 7
        )

        #expect(quota == 2)
    }

    @Test func proRatedQuota_forOneWeeklyOccurrenceOnSunday_returnsZero() {
        let quota = calculator.proRatedQuota(
            totalOccurrences: 1,
            activeDays: 1,
            periodDays: 7
        )

        #expect(quota == 0)
    }

    @Test func proRatedQuota_returnsZeroForInvalidInputs() {
        #expect(calculator.proRatedQuota(totalOccurrences: 0, activeDays: 5, periodDays: 7) == 0)
        #expect(calculator.proRatedQuota(totalOccurrences: 3, activeDays: 0, periodDays: 7) == 0)
        #expect(calculator.proRatedQuota(totalOccurrences: 3, activeDays: 5, periodDays: 0) == 0)
    }
}
