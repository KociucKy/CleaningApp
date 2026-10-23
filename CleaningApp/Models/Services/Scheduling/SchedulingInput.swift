import Foundation

// MARK: - SchedulingInput

@MainActor
struct SchedulingInput {
    // MARK: - Properties

    let tasks: [RoomTask]
    let scheduledTasks: [ScheduledTask]
    let completedTasks: [CompletedTask]
    let skippedTasks: [SkippedTask]
    let today: Date
    let dailyLimit: Int
    let calendar: Calendar
}
