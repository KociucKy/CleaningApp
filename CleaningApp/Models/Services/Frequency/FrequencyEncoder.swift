import Foundation

struct FrequencyEncoder {
	// MARK: - Methods

	func encode(_ frequency: Frequency) -> String {
		switch frequency {
		case .daily:
			"daily"
		case .everyOtherDay:
			"everyOtherDay"
		case let .everyXDays(count):
			"everyXDays(\(count))"
		case let .timesPerWeek(count):
			"timesPerWeek(\(count))"
		case .everyOtherWeek:
			"everyOtherWeek"
		case let .everyXWeeks(count):
			"everyXWeeks(\(count))"
		case let .timesPerMonth(count):
			"timesPerMonth(\(count))"
		case .monthly:
			"monthly"
		case let .everyXMonths(count):
			"everyXMonths(\(count))"
		case .quarterly:
			"quarterly"
		case .biannually:
			"biannually"
		case .yearly:
			"yearly"
		}
	}

	func decode(_ raw: String) -> Frequency {
		if raw == "daily" { return .daily }
		if raw == "everyOtherDay" { return .everyOtherDay }
		if raw == "everyOtherWeek" { return .everyOtherWeek }
		if raw == "monthly" { return .monthly }
		if raw == "quarterly" { return .quarterly }
		if raw == "biannually" { return .biannually }
		if raw == "yearly" { return .yearly }

		if let count = extractInt(from: raw, prefix: "everyXDays") { return .everyXDays(count) }
		if let count = extractInt(from: raw, prefix: "timesPerWeek") { return .timesPerWeek(count) }
		if let count = extractInt(from: raw, prefix: "everyXWeeks") { return .everyXWeeks(count) }
		if let count = extractInt(from: raw, prefix: "timesPerMonth") { return .timesPerMonth(count) }
		if let count = extractInt(from: raw, prefix: "everyXMonths") { return .everyXMonths(count) }

		return .timesPerWeek(1)
	}

	// MARK: - Private

	private func extractInt(from raw: String, prefix: String) -> Int? {
		guard raw.hasPrefix("\(prefix)("), raw.hasSuffix(")") else { return nil }
		let inner = raw.dropFirst("\(prefix)(".count).dropLast()
		return Int(inner)
	}
}
