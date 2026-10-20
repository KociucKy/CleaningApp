import Foundation

// MARK: - CleaningScheduleCoordinator

@MainActor
final class CleaningScheduleCoordinator {
    // MARK: - Properties

    private let roomTaskManager: RoomTaskManager
    private let scheduledTaskManager: ScheduledTaskManager
    private let completedTaskManager: CompletedTaskManager
    private let skippedTaskManager: SkippedTaskManager
    private let schedulingService: SchedulingService
    private let calendar: Calendar

    // MARK: - Init

    init(
        roomTaskManager: RoomTaskManager,
        scheduledTaskManager: ScheduledTaskManager,
        completedTaskManager: CompletedTaskManager,
        skippedTaskManager: SkippedTaskManager,
        schedulingService: SchedulingService = SchedulingService(),
        calendar: Calendar = .current
    ) {
        self.roomTaskManager = roomTaskManager
        self.scheduledTaskManager = scheduledTaskManager
        self.completedTaskManager = completedTaskManager
        self.skippedTaskManager = skippedTaskManager
        self.schedulingService = schedulingService
        self.calendar = calendar
    }

    // MARK: - Methods

    @discardableResult
    func refresh(today: Date, dailyLimit: Int) throws -> ScheduleMutation {
        let mutation = schedulingService.makeMutation(
            input: SchedulingInput(
                tasks: try roomTaskManager.fetchAll(),
                scheduledTasks: try scheduledTaskManager.fetchAll(),
                completedTasks: try completedTaskManager.fetchAll(),
                skippedTasks: try skippedTaskManager.fetchAll(),
                today: today,
                dailyLimit: dailyLimit,
                calendar: calendar
            )
        )

        for occurrence in mutation.occurrencesToUpdate {
            try scheduledTaskManager.update(occurrence)
        }
        for occurrence in mutation.occurrencesToCreate {
            try scheduledTaskManager.save(occurrence)
        }

        return mutation
    }
}
