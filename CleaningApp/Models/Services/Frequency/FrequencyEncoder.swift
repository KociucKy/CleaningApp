import Foundation

struct FrequencyEncoder {
	// MARK: - Methods

	func encode(_ frequency: Frequency) -> String {
		switch frequency {
		case .daily:
			"daily"
		case .everyOtherDay:
			"everyOtherDay"
		case let .everyXDays(x):
			"everyXDays(\(x))"
		case let .timesPerWeek(x):
			"timesPerWeek(\(x))"
		case .everyOtherWeek:
			"everyOtherWeek"
		case let .everyXWeeks(x):
			"everyXWeeks(\(x))"
		case let .timesPerMonth(x):
			"timesPerMonth(\(x))"
		case .monthly:
			"monthly"
		case let .everyXMonths(x):
			"everyXMonths(\(x))"
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

		if let x = extractInt(from: raw, prefix: "everyXDays") { return .everyXDays(x) }
		if let x = extractInt(from: raw, prefix: "timesPerWeek") { return .timesPerWeek(x) }
		if let x = extractInt(from: raw, prefix: "everyXWeeks") { return .everyXWeeks(x) }
		if let x = extractInt(from: raw, prefix: "timesPerMonth") { return .timesPerMonth(x) }
		if let x = extractInt(from: raw, prefix: "everyXMonths") { return .everyXMonths(x) }

		return .weekly
	}

	// MARK: - Private

	private func extractInt(from raw: String, prefix: String) -> Int? {
		guard raw.hasPrefix("\(prefix)("), raw.hasSuffix(")") else { return nil }
		let inner = raw.dropFirst("\(prefix)(".count).dropLast()
		return Int(inner)
	}
}

// MARK: - Frequency + weekly fallback

private extension Frequency {
	static var weekly: Frequency {
		.timesPerWeek(1)
	}
}
