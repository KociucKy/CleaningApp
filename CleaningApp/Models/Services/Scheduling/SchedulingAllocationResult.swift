import Foundation

// MARK: - SchedulingAllocationResult

@MainActor
struct SchedulingAllocationResult: Equatable {
    // MARK: - Properties

    let allocations: [ScheduledCandidateAllocation]
    let unplacedCandidates: [SchedulingCandidate]
}
