import Foundation

@Observable
@MainActor
final class SchedulePresenter {
	// MARK: - Properties

	private let interactor: any ScheduleInteractor
	private let router: any ScheduleRouter
	private(set) var tasksByWeekday: [ScheduleView.Weekday: [ScheduleTaskRow]] = [:]
	private(set) var currentWeekday: ScheduleView.Weekday = .monday
	private var hasPastPlannedOccurrences = false

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
			hasPastPlannedOccurrences = scheduledTasks.contains { scheduledTask in
				scheduledTask.status == .planned && scheduledTask.scheduledDate < startDate
			}
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
		guard let hasActivePlan = fetchSchedule(today: today, calendar: calendar) else {
			return
		}
		if hasPastPlannedOccurrences {
			endElapsedScheduleDay(before: today, calendar: calendar)
			guard let hasActivePlan = fetchSchedule(today: today, calendar: calendar), !hasActivePlan else {
				return
			}
			refresh(today: today)
			return
		}
		guard !hasActivePlan else {
			return
		}

		refresh(today: today)
	}

	func tasks(for day: ScheduleView.Weekday) -> [ScheduleTaskRow] {
		tasksByWeekday[day] ?? []
	}

	func summary(for day: ScheduleView.Weekday) -> ScheduleDaySummary {
		let tasks = tasks(for: day)
		let completedTaskCount = tasks.filter { $0.status == .completed }.count
		let plannedTaskCount = tasks.filter { $0.status == .planned }.count
		let totalTaskCount = tasks.count
		let totalMinutes = tasks.reduce(0) { $0 + $1.duration }

		return ScheduleDaySummary(
			weekdayName: day.name,
			completionText: "\(completedTaskCount)/\(totalTaskCount)",
			taskDescription: totalTaskCount == 0
				? "A clear day — enjoy the space."
				: "\(totalTaskCount) tasks • \(totalMinutes) min planned",
			completedTaskCount: completedTaskCount,
			progressTotal: max(totalTaskCount, 1),
			showsEmptyState: plannedTaskCount == 0
		)
	}

	func complete(_ task: ScheduleTaskRow, completedAt: Date = Date()) {
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

	func uncomplete(_ task: ScheduleTaskRow, uncompletedAt: Date = Date()) {
		guard task.status == .completed else {
			return
		}

		do {
			_ = try interactor.uncompleteScheduledTask(
				id: task.id,
				uncompletedAt: uncompletedAt,
				dailyLimit: interactor.dailyScheduleLimit()
			)
			fetchSchedule(today: uncompletedAt)
		} catch {}
	}

	func skip(_ task: ScheduleTaskRow, skippedAt: Date = Date()) {
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

	func undoSkip(_ task: ScheduleTaskRow, restoredAt: Date = Date()) {
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

	private func endElapsedScheduleDay(before today: Date, calendar: Calendar) {
		guard let yesterday = calendar.date(
			byAdding: .day,
			value: -1,
			to: calendar.startOfDay(for: today)
		) else {
			return
		}

		do {
			_ = try interactor.endScheduleDay(
				endedAt: yesterday,
				dailyLimit: interactor.dailyScheduleLimit()
			)
		} catch {}
	}

	private func makeTasksByWeekday(
		rooms: [Room],
		tasks: [RoomTask],
		scheduledTasks: [ScheduledTask],
		startDate: Date,
		calendar: Calendar
	) -> [ScheduleView.Weekday: [ScheduleTaskRow]] {
		let roomsByID = Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, $0) })
		let tasksByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })

		return scheduledTasks.reduce(into: [ScheduleView.Weekday: [ScheduleTaskRow]]()) { result, occurrence in
			guard occurrence.scheduledDate >= startDate,
				let task = tasksByID[occurrence.taskId],
				let room = roomsByID[task.roomId]
			else {
				return
			}

			let weekday = ScheduleView.Weekday(date: occurrence.scheduledDate, calendar: calendar)
			result[weekday, default: []].append(
				ScheduleTaskRow(
					id: occurrence.id,
					name: task.name,
					roomName: room.name,
					duration: task.learnedDuration ?? task.estimatedDuration.rawValue,
					symbolName: room.kind.symbolName,
					status: occurrence.status
				)
			)
		}
	}
}
