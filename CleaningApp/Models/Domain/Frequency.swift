import Foundation

enum Frequency: Equatable, Codable, Hashable {
	case daily
	case everyOtherDay
	case everyXDays(Int)
	case timesPerWeek(Int)
	case everyOtherWeek
	case everyXWeeks(Int)
	case timesPerMonth(Int)
	case monthly
	case everyXMonths(Int)
	case quarterly
	case biannually
	case yearly

	// MARK: - Display

	var displayName: String {
		switch self {
		case .daily:
			String(localized: "frequency.daily")
		case .everyOtherDay:
			String(localized: "frequency.every_other_day")
		case let .everyXDays(days):
			String.localizedStringWithFormat(String(localized: "frequency.every_x_days"), Int64(days))
		case let .timesPerWeek(times):
			times == 1
				? String(localized: "frequency.once_a_week")
				: String.localizedStringWithFormat(String(localized: "frequency.times_per_week"), Int64(times))
		case .everyOtherWeek:
			String(localized: "frequency.every_other_week")
		case let .everyXWeeks(weeks):
			String.localizedStringWithFormat(String(localized: "frequency.every_x_weeks"), Int64(weeks))
		case let .timesPerMonth(times):
			times == 1
				? String(localized: "frequency.monthly")
				: String.localizedStringWithFormat(String(localized: "frequency.times_per_month"), Int64(times))
		case .monthly:
			String(localized: "frequency.monthly")
		case let .everyXMonths(months):
			String.localizedStringWithFormat(String(localized: "frequency.every_x_months"), Int64(months))
		case .quarterly:
			String(localized: "frequency.quarterly")
		case .biannually:
			String(localized: "frequency.biannually")
		case .yearly:
			String(localized: "frequency.yearly")
		}
	}
}
