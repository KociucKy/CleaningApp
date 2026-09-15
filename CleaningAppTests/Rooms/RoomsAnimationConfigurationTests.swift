import Testing
@testable import CleaningApp

// MARK: - RoomsAnimationConfigurationTests

@Suite(.tags(.rooms))
struct RoomsAnimationConfigurationTests {
    @Test func delay_returnsStaggeredDelayForEachIndex() {
        var configuration = RoomsAnimationConfiguration()
        configuration.stagger = 0.1

        #expect(configuration.delay(for: 0) == 0)
        #expect(abs(configuration.delay(for: 3) - 0.3) < 0.0001)
    }

    @Test func runID_isIncludedInEquatableState() {
        let first = RoomsAnimationConfiguration()
        var second = first
        second.runID = 1

        #expect(first != second)
    }
}
