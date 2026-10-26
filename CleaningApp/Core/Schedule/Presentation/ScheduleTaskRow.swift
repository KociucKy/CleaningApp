import Foundation

// MARK: - ScheduleTaskRow

@MainActor
struct ScheduleTaskRow: Identifiable, Equatable {
    // MARK: - Properties

    let id: UUID
    let name: String
    let roomName: String
    let duration: Int
    let symbolName: String
    let status: ScheduledTaskStatus

    var statusDescription: String {
        switch status {
        case .planned: "Planned"
        case .completed: "Completed"
        case .skipped: "Skipped"
        case .postponed: "Backlog"
        case .cancelled: "Cancelled"
        }
    }

    // MARK: - Init

    init(
        id: UUID,
        name: String,
        roomName: String,
        duration: Int,
        symbolName: String,
        status: ScheduledTaskStatus
    ) {
        self.id = id
        self.name = name
        self.roomName = roomName
        self.duration = duration
        self.symbolName = symbolName
        self.status = status
    }
}
