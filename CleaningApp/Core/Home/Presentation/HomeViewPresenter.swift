import Foundation

// MARK: - HomePresenter

@Observable
@MainActor
final class HomeViewPresenter {
	// MARK: - Properties

	private(set) var rooms: [Room] = []
	private(set) var tasks: [RoomTask] = []
	private(set) var scheduledTasks: [ScheduledTask] = []
	private(set) var scheduledTaskRows: [HomeScheduledTaskRow] = []
	private let interactor: any HomeInteractor
	private let router: any HomeRouter

	var onboardingCompletionToken: Int {
		interactor.onboardingCompletionToken
	}

	var plannedScheduledTaskCount: Int {
		scheduledTasks.filter { $0.status == .planned }.count
	}

	var backlogScheduledTaskCount: Int {
		scheduledTasks.filter { $0.status == .postponed }.count
	}

	var plannedScheduledTaskRows: [HomeScheduledTaskRow] {
		scheduledTaskRows.filter { $0.status == .planned }
	}

	var backlogScheduledTaskRows: [HomeScheduledTaskRow] {
		scheduledTaskRows.filter { $0.status == .postponed }
	}

	// MARK: - Init

	init(interactor: any HomeInteractor, router: any HomeRouter) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Dev Settings

	func showDevSettings() {
		router.presentDevSettings()
	}

	// MARK: - Rooms

	func fetchAllRooms() {
		do {
			rooms = try interactor.fetchAllRooms()
			tasks = try interactor.fetchAllRoomTasks()
			scheduledTasks = try interactor.fetchAllScheduledTasks()
			scheduledTaskRows = makeScheduledTaskRows(tasks: tasks, scheduledTasks: scheduledTasks)
		} catch {}
	}

	// MARK: - Private

	private func makeScheduledTaskRows(
		tasks: [RoomTask],
		scheduledTasks: [ScheduledTask]
	) -> [HomeScheduledTaskRow] {
		let tasksByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })

		return scheduledTasks.compactMap { scheduledTask in
			guard let task = tasksByID[scheduledTask.taskId] else {
				return nil
			}

			return HomeScheduledTaskRow(
				id: scheduledTask.id,
				name: task.name,
				duration: task.learnedDuration ?? task.estimatedDuration.rawValue,
				status: scheduledTask.status
			)
		}
	}
}
