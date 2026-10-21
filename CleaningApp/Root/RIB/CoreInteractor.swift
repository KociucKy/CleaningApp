import Foundation

// MARK: - CoreInteractor

@MainActor
struct CoreInteractor {
	// MARK: - Properties

	private enum Constants {
		static let defaultDailyLimit = 30
	}

	private let roomManager: RoomManager
	private let roomTaskManager: RoomTaskManager
	private let scheduledTaskManager: ScheduledTaskManager
	private let completedTaskManager: CompletedTaskManager
	private let skippedTaskManager: SkippedTaskManager
	private let cleaningScheduleCoordinator: CleaningScheduleCoordinator
	private let notificationScheduler: any NotificationScheduling
	private let completionTrendService: any CompletionTrendServicing
	private let onboardingState: OnboardingState

	var onboardingCompletionToken: Int {
		onboardingState.completionToken
	}

	// MARK: - Init

	init(container: DependencyContainer) {
		roomManager = container.resolve(RoomManager.self)!
		roomTaskManager = container.resolve(RoomTaskManager.self)!
		scheduledTaskManager = container.resolve(ScheduledTaskManager.self)!
		completedTaskManager = container.resolve(CompletedTaskManager.self)!
		skippedTaskManager = container.resolve(SkippedTaskManager.self)!
		cleaningScheduleCoordinator = container.resolve(CleaningScheduleCoordinator.self)!
		notificationScheduler = container.resolve(NotificationScheduling.self)!
		completionTrendService = container.resolve(CompletionTrendServicing.self)!
		onboardingState = container.resolve(OnboardingState.self)!
	}

	// MARK: - Room Manager

	func fetchAllRooms() throws -> [Room] {
		try roomManager.fetchAll()
	}

	func saveRoom(_ item: Room) throws {
		try roomManager.save(item)
	}

	func updateRoom(_ item: Room) throws {
		try roomManager.update(item)
	}

	func deleteRoom(_ item: Room) throws {
		try roomManager.delete(item)
	}

	func saveCustomRoom(name: String, icon: String) throws {
		let room = Room(
			name: name,
			kind: .customRoom,
			isCustom: true,
			customIcon: icon
		)
		try roomManager.save(room)
	}

	// MARK: - Room Task Manager

	func fetchAllRoomTasks() throws -> [RoomTask] {
		try roomTaskManager.fetchAll()
	}

	func fetchAllRoomTasks(for roomId: UUID) throws -> [RoomTask] {
		try roomTaskManager.fetchAll(for: roomId)
	}

	func saveRoomTask(_ item: RoomTask) throws {
		try roomTaskManager.save(item)
		try refreshScheduleAfterTaskChange()
	}

	func deleteRoomTask(_ item: RoomTask) throws {
		try roomTaskManager.delete(item)
		try refreshScheduleAfterTaskChange()
	}

	func updateRoomTask(_ item: RoomTask) throws {
		try roomTaskManager.update(item)
		try refreshScheduleAfterTaskChange()
	}

	// MARK: - Schedule

	func fetchAllScheduledTasks() throws -> [ScheduledTask] {
		try scheduledTaskManager.fetchAll()
	}

	func refreshSchedule(today: Date, dailyLimit: Int) throws -> ScheduleMutation {
		try cleaningScheduleCoordinator.refresh(today: today, dailyLimit: dailyLimit)
	}

	func completeScheduledTask(
		id: UUID,
		completedAt: Date,
		measuredDuration: Int? = nil
	) throws {
		try cleaningScheduleCoordinator.complete(
			scheduledTaskId: id,
			completedAt: completedAt,
			measuredDuration: measuredDuration
		)
	}

	func skipScheduledTask(id: UUID, skippedAt: Date, dailyLimit: Int) throws -> ScheduleMutation {
		try cleaningScheduleCoordinator.skip(
			scheduledTaskId: id,
			skippedAt: skippedAt,
			dailyLimit: dailyLimit
		)
	}

	func undoSkipScheduledTask(id: UUID, restoredAt: Date) throws {
		try cleaningScheduleCoordinator.undoSkip(scheduledTaskId: id, restoredAt: restoredAt)
	}

	func endScheduleDay(endedAt: Date, dailyLimit: Int) throws -> ScheduleMutation {
		try cleaningScheduleCoordinator.endDay(endedAt: endedAt, dailyLimit: dailyLimit)
	}

	// MARK: - Private

	private func refreshScheduleAfterTaskChange() throws {
		try cleaningScheduleCoordinator.refresh(
			today: Date(),
			dailyLimit: Constants.defaultDailyLimit
		)
	}

	// MARK: - Completed Task Manager

	func fetchAllCompletedTasks() throws -> [CompletedTask] {
		try completedTaskManager.fetchAll()
	}

	func fetchAllCompletedTasks(for taskId: UUID) throws -> [CompletedTask] {
		try completedTaskManager.fetchAll(for: taskId)
	}

	func fetchAllCompletedTasks(forTaskIDs taskIDs: [UUID]) throws -> [CompletedTask] {
		try completedTaskManager.fetchAll(forTaskIDs: taskIDs)
	}

	func fetchAllCompletedTasks(forRoomId roomId: UUID) throws -> [CompletedTask] {
		try completedTaskManager.fetchAll(forRoomId: roomId)
	}

	func fetchCompletedTasks(
		forRoomId roomId: UUID,
		limit: Int,
		offset: Int
	) throws -> [CompletedTask] {
		try completedTaskManager.fetchAll(forRoomId: roomId, limit: limit, offset: offset)
	}

	func saveCompletedTask(_ item: CompletedTask) throws {
		try completedTaskManager.save(item)
	}

	func updateCompletedTask(_ item: CompletedTask) throws {
		try completedTaskManager.update(item)
	}

	func deleteCompletedTask(_ item: CompletedTask) throws {
		try completedTaskManager.delete(item)
	}

	// MARK: - Completion Trend Service

	func makeCompletionTrend(
		from completedTasks: [CompletedTask],
		tasks: [RoomTask],
		range: CompletionTrendRange
	) -> [CompletionChartDataPoint] {
		completionTrendService.makeCompletionTrend(
			from: completedTasks,
			tasks: tasks,
			range: range
		)
	}

	// MARK: - Skipped Task Manager

	func fetchAllSkippedTasks() throws -> [SkippedTask] {
		try skippedTaskManager.fetchAll()
	}

	func fetchAllSkippedTasks(for taskId: UUID) throws -> [SkippedTask] {
		try skippedTaskManager.fetchAll(for: taskId)
	}

	func saveSkippedTask(_ item: SkippedTask) throws {
		try skippedTaskManager.save(item)
	}

	func deleteSkippedTask(_ item: SkippedTask) throws {
		try skippedTaskManager.delete(item)
	}
}
