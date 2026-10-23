import Foundation

// MARK: - SchedulingRecurrenceCalculator

@MainActor
final class SchedulingRecurrenceCalculator {
    // MARK: - Methods

    func rule(for frequency: Frequency) -> SchedulingFrequencyRule {
        switch frequency.canonicalized {
        case .daily:
            .intervalDays(1)
        case let .everyXDays(days):
            .intervalDays(max(days, 1))
        case let .timesPerWeek(times):
            .weeklyQuota(max(times, 1))
        case let .everyXWeeks(weeks):
            .intervalWeeks(max(weeks, 1))
        case let .timesPerMonth(times):
            .monthlyQuota(max(times, 1))
        case let .everyXMonths(months):
            .intervalMonths(max(months, 1))
        case .everyOtherDay, .everyOtherWeek, .monthly, .quarterly, .biannually, .yearly:
            preconditionFailure("Frequency aliases must be canonicalized before rule evaluation.")
        }
    }

    func proRatedQuota(
        totalOccurrences: Int,
        activeDays: Int,
        periodDays: Int
    ) -> Int {
        guard totalOccurrences > 0, activeDays > 0, periodDays > 0 else {
            return 0
        }

        let quota = Double(totalOccurrences) * Double(activeDays) / Double(periodDays)
        return Int(quota.rounded())
    }
}
