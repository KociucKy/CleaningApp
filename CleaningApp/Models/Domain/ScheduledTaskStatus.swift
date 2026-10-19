import Foundation

// MARK: - ScheduledTaskStatus

@MainActor
enum ScheduledTaskStatus: String, Codable, Hashable {
    case planned
    case completed
    case skipped
    case postponed
    case cancelled
}
