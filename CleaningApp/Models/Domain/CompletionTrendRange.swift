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
			"7D"
		case .thirtyDays:
			"30D"
		case .ninetyDays:
			"90D"
		case .oneYear:
			"1Y"
		}
	}
}
