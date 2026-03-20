import Foundation
import Testing
@testable import CleaningApp

// MARK: - FrequencyEncoderTests

@Suite(.tags(.persistence))
@MainActor
struct FrequencyEncoderTests {
	private let encoder = FrequencyEncoder()

	// MARK: - Encode

	@Test func encode_daily() {
		#expect(encoder.encode(.daily) == "daily")
	}

	@Test func encode_everyOtherDay() {
		#expect(encoder.encode(.everyOtherDay) == "everyOtherDay")
	}

	@Test func encode_everyXDays() {
		#expect(encoder.encode(.everyXDays(3)) == "everyXDays(3)")
		#expect(encoder.encode(.everyXDays(1)) == "everyXDays(1)")
	}

	@Test func encode_timesPerWeek() {
		#expect(encoder.encode(.timesPerWeek(2)) == "timesPerWeek(2)")
		#expect(encoder.encode(.timesPerWeek(1)) == "timesPerWeek(1)")
	}

	@Test func encode_everyOtherWeek() {
		#expect(encoder.encode(.everyOtherWeek) == "everyOtherWeek")
	}

	@Test func encode_everyXWeeks() {
		#expect(encoder.encode(.everyXWeeks(2)) == "everyXWeeks(2)")
	}

	@Test func encode_timesPerMonth() {
		#expect(encoder.encode(.timesPerMonth(3)) == "timesPerMonth(3)")
	}

	@Test func encode_monthly() {
		#expect(encoder.encode(.monthly) == "monthly")
	}

	@Test func encode_everyXMonths() {
		#expect(encoder.encode(.everyXMonths(3)) == "everyXMonths(3)")
	}

	@Test func encode_quarterly() {
		#expect(encoder.encode(.quarterly) == "quarterly")
	}

	@Test func encode_biannually() {
		#expect(encoder.encode(.biannually) == "biannually")
	}

	@Test func encode_yearly() {
		#expect(encoder.encode(.yearly) == "yearly")
	}

	// MARK: - Decode

	@Test func decode_daily() {
		#expect(encoder.decode("daily") == .daily)
	}

	@Test func decode_everyOtherDay() {
		#expect(encoder.decode("everyOtherDay") == .everyOtherDay)
	}

	@Test func decode_everyXDays() {
		#expect(encoder.decode("everyXDays(3)") == .everyXDays(3))
		#expect(encoder.decode("everyXDays(1)") == .everyXDays(1))
	}

	@Test func decode_timesPerWeek() {
		#expect(encoder.decode("timesPerWeek(2)") == .timesPerWeek(2))
		#expect(encoder.decode("timesPerWeek(1)") == .timesPerWeek(1))
	}

	@Test func decode_everyOtherWeek() {
		#expect(encoder.decode("everyOtherWeek") == .everyOtherWeek)
	}

	@Test func decode_everyXWeeks() {
		#expect(encoder.decode("everyXWeeks(2)") == .everyXWeeks(2))
	}

	@Test func decode_timesPerMonth() {
		#expect(encoder.decode("timesPerMonth(3)") == .timesPerMonth(3))
	}

	@Test func decode_monthly() {
		#expect(encoder.decode("monthly") == .monthly)
	}

	@Test func decode_everyXMonths() {
		#expect(encoder.decode("everyXMonths(3)") == .everyXMonths(3))
	}

	@Test func decode_quarterly() {
		#expect(encoder.decode("quarterly") == .quarterly)
	}

	@Test func decode_biannually() {
		#expect(encoder.decode("biannually") == .biannually)
	}

	@Test func decode_yearly() {
		#expect(encoder.decode("yearly") == .yearly)
	}

	@Test func decode_unknownString_returnsFallback() {
		#expect(encoder.decode("unknown") == .timesPerWeek(1))
		#expect(encoder.decode("") == .timesPerWeek(1))
	}

	// MARK: - Round-trip

	@Test(
		"encode then decode returns original value",
		arguments: [
			Frequency.daily,
			.everyOtherDay,
			.everyXDays(3),
			.timesPerWeek(2),
			.everyOtherWeek,
			.everyXWeeks(2),
			.timesPerMonth(3),
			.monthly,
			.everyXMonths(3),
			.quarterly,
			.biannually,
			.yearly
		]
	)
	func roundTrip(frequency: Frequency) {
		let encoded = encoder.encode(frequency)
		let decoded = encoder.decode(encoded)
		#expect(decoded == frequency)
	}
}
