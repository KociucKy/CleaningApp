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

    func complete(
        scheduledTaskId: UUID,
        completedAt: Date,
        measuredDuration: Int? = nil
    ) throws {
        guard var scheduledTask = try scheduledTaskManager.fetchSingle(for: scheduledTaskId) else {
            throw CleaningScheduleCoordinatorError.scheduledTaskNotFound
        }
        guard scheduledTask.status == .planned else {
            throw CleaningScheduleCoordinatorError.scheduledTaskIsNotPlanned
        }

        scheduledTask.status = .completed
        scheduledTask.updatedAt = completedAt
        try scheduledTaskManager.update(scheduledTask)
        try completedTaskManager.save(
            CompletedTask(
                taskId: scheduledTask.taskId,
                scheduledTaskId: scheduledTask.id,
                completedAt: completedAt,
                measuredDuration: measuredDuration
            )
        )
    }

    @discardableResult
    func uncomplete(
        scheduledTaskId: UUID,
        uncompletedAt: Date,
        dailyLimit: Int
    ) throws -> ScheduleMutation {
        guard var scheduledTask = try scheduledTaskManager.fetchSingle(for: scheduledTaskId) else {
            throw CleaningScheduleCoordinatorError.scheduledTaskNotFound
        }
        guard scheduledTask.status == .completed else {
            throw CleaningScheduleCoordinatorError.scheduledTaskIsNotCompleted
        }
        guard let completedTask = try completedTaskManager.fetchAll().first(where: {
            $0.scheduledTaskId == scheduledTaskId
        }) else {
            throw CleaningScheduleCoordinatorError.completedTaskHistoryNotFound
        }

        scheduledTask.status = .planned
        scheduledTask.updatedAt = uncompletedAt
        try scheduledTaskManager.update(scheduledTask)
        try completedTaskManager.delete(completedTask)

        return try refresh(today: uncompletedAt, dailyLimit: dailyLimit)
    }

    @discardableResult
    func skip(
        scheduledTaskId: UUID,
        skippedAt: Date,
        dailyLimit: Int
    ) throws -> ScheduleMutation {
        guard var scheduledTask = try scheduledTaskManager.fetchSingle(for: scheduledTaskId) else {
            throw CleaningScheduleCoordinatorError.scheduledTaskNotFound
        }
        guard scheduledTask.status == .planned else {
            throw CleaningScheduleCoordinatorError.scheduledTaskIsNotPlanned
        }
        guard let task = try roomTaskManager.fetchAll().first(where: { $0.id == scheduledTask.taskId }) else {
            throw CleaningScheduleCoordinatorError.roomTaskNotFound
        }
        guard let tomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: skippedAt)
        ) else {
            throw CleaningScheduleCoordinatorError.couldNotCalculateSuccessorDate
        }

        scheduledTask.status = .skipped
        scheduledTask.updatedAt = skippedAt
        try scheduledTaskManager.update(scheduledTask)
        try skippedTaskManager.save(
            SkippedTask(
                taskId: scheduledTask.taskId,
                scheduledTaskId: scheduledTask.id,
                originalDate: scheduledTask.originalScheduledDate,
                skippedAt: skippedAt
            )
        )

        let mutation = schedulingService.makeSkipSuccessorMutation(
            task: task,
            skippedOccurrence: scheduledTask,
            input: SchedulingInput(
                tasks: try roomTaskManager.fetchAll(),
                scheduledTasks: try scheduledTaskManager.fetchAll(),
                completedTasks: try completedTaskManager.fetchAll(),
                skippedTasks: try skippedTaskManager.fetchAll(),
                today: tomorrow,
                dailyLimit: dailyLimit,
                calendar: calendar
            )
        )
        for occurrence in mutation.occurrencesToCreate {
            try scheduledTaskManager.save(occurrence)
        }

        return mutation
    }

    func undoSkip(scheduledTaskId: UUID, restoredAt: Date) throws {
        guard var scheduledTask = try scheduledTaskManager.fetchSingle(for: scheduledTaskId) else {
            throw CleaningScheduleCoordinatorError.scheduledTaskNotFound
        }
        guard scheduledTask.status == .skipped else {
            throw CleaningScheduleCoordinatorError.scheduledTaskIsNotSkipped
        }
        guard let skippedTask = try skippedTaskManager.fetchAll().first(where: {
            $0.scheduledTaskId == scheduledTaskId
        }) else {
            throw CleaningScheduleCoordinatorError.skippedTaskHistoryNotFound
        }

        scheduledTask.status = .planned
        scheduledTask.updatedAt = restoredAt
        try scheduledTaskManager.update(scheduledTask)

        let successors = try scheduledTaskManager.fetchAll().filter {
            $0.sourceOccurrenceId == scheduledTaskId
                && ($0.status == .planned || $0.status == .postponed)
        }
        for var successor in successors {
            successor.status = .cancelled
            successor.updatedAt = restoredAt
            try scheduledTaskManager.update(successor)
        }
        try skippedTaskManager.delete(skippedTask)
    }

    @discardableResult
    func endDay(endedAt: Date, dailyLimit: Int) throws -> ScheduleMutation {
        let endDate = calendar.startOfDay(for: endedAt)
        let incompleteOccurrences = try scheduledTaskManager.fetchAll().filter {
            $0.status == .planned && $0.scheduledDate <= endDate
        }
        for var occurrence in incompleteOccurrences {
            occurrence.status = .postponed
            occurrence.updatedAt = endedAt
            try scheduledTaskManager.update(occurrence)
        }
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: endDate) else {
            throw CleaningScheduleCoordinatorError.couldNotCalculateSuccessorDate
        }

        return try refresh(today: tomorrow, dailyLimit: dailyLimit)
    }
}
