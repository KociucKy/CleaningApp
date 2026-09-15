import Foundation

// MARK: - CompletionTrendRange

enum CompletionTrendRange: CaseIterable, Hashable {
	// MARK: - Cases

	case sevenDays
	case thirtyDays
	case ninetyDays
	case oneYear

	// MARK: - Properties

	var days: Int {
		switch self {
		case .sevenDays:
			7
		case .thirtyDays:
			30
		case .ninetyDays:
			90
		case .oneYear:
			365
		}
	}

	var title: String {
		switch self {
		case .sevenDays:
			String(localized: "chart.range.seven_days", defaultValue: "7 days")
		case .thirtyDays:
			String(localized: "chart.range.thirty_days", defaultValue: "30 days")
		case .ninetyDays:
			String(localized: "chart.range.ninety_days", defaultValue: "90 days")
		case .oneYear:
			String(localized: "chart.range.one_year", defaultValue: "1 year")
		}
	}
}
