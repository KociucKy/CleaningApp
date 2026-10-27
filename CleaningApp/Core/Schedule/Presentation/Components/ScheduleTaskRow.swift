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
		case .planned: String(localized: .init("schedule.status.planned", defaultValue: "Planned"))
		case .completed: String(localized: .init("schedule.status.completed", defaultValue: "Completed"))
		case .skipped: String(localized: .init("schedule.status.skipped", defaultValue: "Skipped"))
		case .postponed: String(localized: .init("schedule.status.postponed", defaultValue: "Backlog"))
		case .cancelled: String(localized: .init("schedule.status.cancelled", defaultValue: "Cancelled"))
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
