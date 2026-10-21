import Foundation

// MARK: - HomeScheduledTaskRow

@MainActor
struct HomeScheduledTaskRow: Identifiable, Equatable {
    // MARK: - Properties

    let id: UUID
    let name: String
    let duration: Int
    let status: ScheduledTaskStatus
}
