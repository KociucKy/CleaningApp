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
}
