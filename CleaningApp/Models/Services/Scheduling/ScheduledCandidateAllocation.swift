import Foundation

// MARK: - ScheduledCandidateAllocation

@MainActor
struct ScheduledCandidateAllocation: Equatable {
    // MARK: - Properties

    let candidate: SchedulingCandidate
    let scheduledDate: Date
}
