import Foundation

// MARK: - SchedulingOccurrenceAnalysis

@MainActor
struct SchedulingOccurrenceAnalysis: Equatable {
    // MARK: - Properties

    let preservedOccurrences: [ScheduledTask]
    let overdueOccurrences: [ScheduledTask]
    let backlogOccurrences: [ScheduledTask]
}
