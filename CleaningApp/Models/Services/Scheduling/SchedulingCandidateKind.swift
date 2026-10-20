import Foundation

// MARK: - SchedulingCandidateKind

@MainActor
enum SchedulingCandidateKind: Equatable {
    case backlog
    case overdue
    case regular
}
