import Testing
@testable import CleaningApp

// MARK: - FrequencySelectorOptionTests

@Suite(.tags(.critical))
@MainActor
struct FrequencySelectorOptionTests {
    // MARK: - Canonicalization

    @Test(
        "canonicalizes legacy frequency aliases",
        arguments: [
            (Frequency.everyOtherDay, Frequency.everyXDays(2)),
            (.everyOtherWeek, .everyXWeeks(2)),
            (.monthly, .timesPerMonth(1)),
            (.quarterly, .everyXMonths(3)),
            (.biannually, .everyXMonths(6)),
            (.yearly, .everyXMonths(12))
        ]
    )
    func canonicalized_legacyFrequency_returnsEquivalentCanonicalFrequency(
        frequency: Frequency,
        expectedFrequency: Frequency
    ) {
        #expect(frequency.canonicalized == expectedFrequency)
    }

    // MARK: - Options

    @Test(
        "identifies the selector option for each frequency shape",
        arguments: [
            (Frequency.daily, FrequencySelectorOption.daily),
            (.everyXDays(4), .everyXDays),
            (.timesPerWeek(3), .timesPerWeek),
            (.everyXWeeks(4), .everyXWeeks),
            (.timesPerMonth(3), .timesPerMonth),
            (.everyXMonths(4), .everyXMonths)
        ]
    )
    func init_frequency_returnsMatchingOption(
        frequency: Frequency,
        expectedOption: FrequencySelectorOption
    ) {
        #expect(FrequencySelectorOption(frequency: frequency) == expectedOption)
    }

    @Test(
        "bounds count-based frequencies",
        arguments: [
            (FrequencySelectorOption.everyXDays, 1, Frequency.everyXDays(2)),
            (.timesPerWeek, 8, .timesPerWeek(7)),
            (.everyXWeeks, 1, .everyXWeeks(2)),
            (.timesPerMonth, 32, .timesPerMonth(31)),
            (.everyXMonths, 25, .everyXMonths(24))
        ]
    )
    func frequency_outOfBoundsCount_returnsBoundedFrequency(
        option: FrequencySelectorOption,
        count: Int,
        expectedFrequency: Frequency
    ) {
        #expect(option.frequency(for: count) == expectedFrequency)
    }
}
