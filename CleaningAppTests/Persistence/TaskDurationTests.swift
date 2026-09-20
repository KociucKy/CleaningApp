import Testing
@testable import CleaningApp

// MARK: - TaskDurationTests

@Suite(.tags(.persistence))
struct TaskDurationTests {
    @Test func allCases_containsEveryFiveMinuteValue() {
        #expect(TaskDuration.allCases.map(\.rawValue) == Array(stride(from: 5, through: 60, by: 5)))
    }

    @Test func rawValue_roundTripsAllSupportedDurations() {
        for duration in TaskDuration.allCases {
            #expect(TaskDuration(rawValue: duration.rawValue) == duration)
        }
    }
}
