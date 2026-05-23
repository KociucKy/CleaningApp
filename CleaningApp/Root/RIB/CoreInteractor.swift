import Foundation

// MARK: - CoreInteractor

@MainActor
struct CoreInteractor {
	// MARK: - Properties

	private let roomManager: RoomManager
	private let roomTaskManager: RoomTaskManager
	private let completedTaskManager: CompletedTaskManager
	private let skippedTaskManager: SkippedTaskManager
	private let notificationScheduler: any NotificationScheduling
	private let onboardingState: OnboardingState

	var onboardingCompletionToken: Int {
		onboardingState.completionToken
	}

	// MARK: - Init

	init(container: DependencyContainer) {
		roomManager = container.resolve(RoomManager.self)!
		roomTaskManager = container.resolve(RoomTaskManager.self)!
		completedTaskManager = container.resolve(CompletedTaskManager.self)!
		skippedTaskManager = container.resolve(SkippedTaskManager.self)!
		notificationScheduler = container.resolve(NotificationScheduling.self)!
		onboardingState = container.resolve(OnboardingState.self)!
	}

	// MARK: - Room Manager

	func fetchAllRooms() throws -> [Room] {
		try roomManager.fetchAll()
	}

	func saveRoom(_ item: Room) throws {
		try roomManager.save(item)
	}

	func deleteRoom(_ item: Room) throws {
		try roomManager.delete(item)
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
	}

	func deleteRoomTask(_ item: RoomTask) throws {
		try roomTaskManager.delete(item)
	}

	// MARK: - Completed Task Manager

	func fetchAllCompletedTasks() throws -> [CompletedTask] {
		try completedTaskManager.fetchAll()
	}

	func fetchAllCompletedTasks(for taskId: UUID) throws -> [CompletedTask] {
		try completedTaskManager.fetchAll(for: taskId)
	}

	func saveCompletedTask(_ item: CompletedTask) throws {
		try completedTaskManager.save(item)
	}

	func deleteCompletedTask(_ item: CompletedTask) throws {
		try completedTaskManager.delete(item)
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
