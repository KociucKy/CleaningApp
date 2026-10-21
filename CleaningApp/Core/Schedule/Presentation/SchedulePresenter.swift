import Foundation

@Observable
@MainActor
final class SchedulePresenter {
	// MARK: - Properties

	private let interactor: any ScheduleInteractor
	private let router: any ScheduleRouter
	private(set) var tasksByWeekday: [ScheduleView.Weekday: [ScheduleView.ScheduleTask]] = [:]
	private(set) var currentWeekday: ScheduleView.Weekday = .monday

	// MARK: - Init

	init(
		interactor: any ScheduleInteractor,
		router: any ScheduleRouter
	) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Methods

	func fetchSchedule(today: Date, calendar: Calendar = .current) {
		do {
			let rooms = try interactor.fetchAllRooms()
			let tasks = try interactor.fetchAllRoomTasks()
			let scheduledTasks = try interactor.fetchAllScheduledTasks()
			let startDate = calendar.startOfDay(for: today)
			currentWeekday = ScheduleView.Weekday(date: startDate, calendar: calendar)
			tasksByWeekday = makeTasksByWeekday(
			rooms: rooms,
			tasks: tasks,
			scheduledTasks: scheduledTasks,
			startDate: startDate,
			calendar: calendar
		)
		} catch {}
	}

	func tasks(for day: ScheduleView.Weekday) -> [ScheduleView.ScheduleTask] {
		tasksByWeekday[day] ?? []
	}

	// MARK: - Private

	private func makeTasksByWeekday(
		rooms: [Room],
		tasks: [RoomTask],
		scheduledTasks: [ScheduledTask],
		startDate: Date,
		calendar: Calendar
	) -> [ScheduleView.Weekday: [ScheduleView.ScheduleTask]] {
		let roomsByID = Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, $0) })
		let tasksByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })

		return scheduledTasks.reduce(into: [ScheduleView.Weekday: [ScheduleView.ScheduleTask]]()) { result, occurrence in
			guard occurrence.scheduledDate >= startDate,
				let task = tasksByID[occurrence.taskId],
				let room = roomsByID[task.roomId]
			else {
				return
			}

			let weekday = ScheduleView.Weekday(date: occurrence.scheduledDate, calendar: calendar)
			result[weekday, default: []].append(
				ScheduleView.ScheduleTask(
					id: occurrence.id,
					name: task.name,
					room: room.name,
					duration: task.learnedDuration ?? task.estimatedDuration.rawValue,
					symbolName: room.kind.symbolName,
					status: occurrence.status
				)
			)
		}
	}
}
