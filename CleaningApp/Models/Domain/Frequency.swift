import Foundation

enum Frequency: Equatable, Codable {
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
		case .daily: "Every day"
		case .everyOtherDay: "Every other day"
		case let .everyXDays(days): "Every \(days) days"
		case let .timesPerWeek(times): times == 1 ? "Once a week" : "\(times)× per week"
		case .everyOtherWeek: "Every other week"
		case let .everyXWeeks(weeks): "Every \(weeks) weeks"
		case let .timesPerMonth(times): times == 1 ? "Once a month" : "\(times)× per month"
		case .monthly: "Once a month"
		case let .everyXMonths(months): "Every \(months) months"
		case .quarterly: "Every 3 months"
		case .biannually: "Twice a year"
		case .yearly: "Once a year"
		}
	}
}
