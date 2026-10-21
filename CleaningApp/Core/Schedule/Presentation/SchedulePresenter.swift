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

	@discardableResult
	func fetchSchedule(today: Date, calendar: Calendar = .current) -> Bool? {
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

			return scheduledTasks.contains { scheduledTask in
				scheduledTask.status == .planned && scheduledTask.scheduledDate >= startDate
			}
		} catch {
			return nil
		}
	}

	func ensureSchedule(today: Date, calendar: Calendar = .current) {
		guard let hasActivePlan = fetchSchedule(today: today, calendar: calendar), !hasActivePlan else {
			return
		}

		refresh(today: today)
	}

	func tasks(for day: ScheduleView.Weekday) -> [ScheduleView.ScheduleTask] {
		tasksByWeekday[day] ?? []
	}

	func complete(_ task: ScheduleView.ScheduleTask, completedAt: Date = Date()) {
		guard task.status == .planned else {
			return
		}

		do {
			try interactor.completeScheduledTask(
				id: task.id,
				completedAt: completedAt,
				measuredDuration: nil
			)
			fetchSchedule(today: completedAt)
		} catch {}
	}

	func skip(_ task: ScheduleView.ScheduleTask, skippedAt: Date = Date()) {
		guard task.status == .planned else {
			return
		}

		do {
			_ = try interactor.skipScheduledTask(
				id: task.id,
				skippedAt: skippedAt,
				dailyLimit: interactor.dailyScheduleLimit()
			)
			fetchSchedule(today: skippedAt)
		} catch {}
	}

	func undoSkip(_ task: ScheduleView.ScheduleTask, restoredAt: Date = Date()) {
		guard task.status == .skipped else {
			return
		}

		do {
			try interactor.undoSkipScheduledTask(id: task.id, restoredAt: restoredAt)
			fetchSchedule(today: restoredAt)
		} catch {}
	}

	func refresh(today: Date = Date()) {
		do {
			_ = try interactor.refreshSchedule(
				today: today,
				dailyLimit: interactor.dailyScheduleLimit()
			)
			fetchSchedule(today: today)
		} catch {}
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
