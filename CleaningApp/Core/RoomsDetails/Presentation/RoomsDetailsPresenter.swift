import FulhamKit
import SwiftUI

@Observable
@MainActor
final class RoomsDetailsPresenter {
	// MARK: - Properties

	private let interactor: any RoomsDetailsInteractor
	private let router: any RoomsDetailsRouter
	private(set) var room: Room

	private(set) var tasks: [RoomTask] = []
	private(set) var frequencies: [Frequency] = []
	private(set) var tasksByFrequency: [Frequency: [RoomTask]] = [:]
	private(set) var completedTaskIDs: Set<UUID> = []
	private(set) var completionTrend: [CompletionChartDataPoint] = []
	private(set) var isLoading = true
	private(set) var reloadToken = 0
	private(set) var errorMessage: String?
	private(set) var animate = false
	var isHeaderVisible = true
	let animationConfig = RoomsAnimationConfiguration()

	var totalDuration: Int {
		tasks.reduce(0) { $0 + $1.estimatedDuration.rawValue }
	}

	var totalTasksCount: Int {
		tasks.count
	}

	// MARK: - Init

	init(
		interactor: any RoomsDetailsInteractor,
		router: any RoomsDetailsRouter,
		room: Room
	) {
		self.interactor = interactor
		self.router = router
		self.room = room
	}

	// MARK: - Actions

	func onAppear(roomId: UUID) {
		guard isLoading else {
			return
		}

		reloadTasks(for: roomId)
	}

	func reloadTasks(for roomId: UUID) {
		do {
			tasks = try interactor.fetchAllRoomTasks(for: roomId).sorted { $0.name < $1.name }
			var seenFrequencies = Set<Frequency>()
			frequencies = tasks.compactMap { task in
				seenFrequencies.insert(task.frequency).inserted ? task.frequency : nil
			}
			tasksByFrequency = Dictionary(grouping: tasks, by: \.frequency)
			reloadToken &+= 1
			let completedTasks = try tasks.flatMap { task in
				try interactor.fetchAllCompletedTasks(for: task.id)
			}
			completedTaskIDs = Set(completedTasks.map(\.taskId))
			completionTrend = makeCompletionTrend(from: completedTasks)
		} catch {
			errorMessage = "Unable to load this room’s tasks."
		}

		isLoading = false
	}

	func onDeleteTaskButtonTapped(_ task: RoomTask, roomId: UUID) {
		router.showAlert(
			.alert,
			title: "Are you sure you want to delete \(task.name)",
			subtitle: nil,
			buttons: { @MainActor in
				Group {
					Button("Yes", role: .destructive) {
						FKHaptics.notification(.warning)
						self.deleteTask(task, roomId: roomId)
					}
					Button("Cancel", role: .cancel) {
						self.router.dismissAlert()
					}
				}.any()
			}
		)
	}

	func restartEntranceAnimation() {
		var transaction = Transaction()
		transaction.animation = nil
		withTransaction(transaction) {
			animate = false
		}

		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			withAnimation(.easeOut(duration: self.animationConfig.duration)) {
				self.animate = true
			}
		}
	}

	func onAddTaskButtonTapped(roomId: UUID) {
		router.presentCustomTaskSheet(roomId: roomId, task: nil) { [self] _ in
			reloadTasks(for: roomId)
		}
	}

	func onEditRoomButtonTapped() {
		router.presentCustomRoomSheet(room: room) { [self] updatedRoom in
			room = updatedRoom
		}
	}

	func onDeleteRoomButtonTapped() {
		router.showAlert(
			.alert,
			title: "Are you sure you want to delete \(room.name)",
			subtitle: nil,
			buttons: { @MainActor in
				Group {
					Button("Yes", role: .destructive) {
						FKHaptics.notification(.warning)
						self.deleteRoom()
					}
					Button("Cancel", role: .cancel) {
						self.router.dismissAlert()
					}
				}.any()
			}
		)
	}

	func onTaskCompletionTapped(_ task: RoomTask) {
		router.presentRoomsDetailsTaskCompletionSheet(
			props: RoomsDetailsTaskCompletionProps(
				taskId: task.id,
				taskName: task.name
			)
		)
	}

	func onEditTaskButtonTapped(_ task: RoomTask) {
		router.presentCustomTaskSheet(roomId: task.roomId, task: task) { [self] _ in
			reloadTasks(for: task.roomId)
		}
	}

	// MARK: - Private

	private func makeCompletionTrend(from completedTasks: [CompletedTask]) -> [CompletionChartDataPoint] {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())
		let dates = (0..<7).compactMap {
			calendar.date(byAdding: .day, value: $0 - 6, to: today)
		}
		let completionsByDay = Dictionary(
			grouping: completedTasks,
			by: { calendar.startOfDay(for: $0.completedAt) }
		)

		return dates.map { date in
			CompletionChartDataPoint(
				date: date,
				completedCount: completionsByDay[date]?.count ?? 0
			)
		}
	}

	private func deleteTask(_ task: RoomTask, roomId: UUID) {
		do {
			try interactor.deleteRoomTask(task)
			withAnimation {
				reloadTasks(for: roomId)
			}
		} catch {
			errorMessage = "Unable to delete this task."
		}
	}

	private func deleteRoom() {
		do {
			try interactor.deleteRoom(room)
			router.dismissScreen()
		} catch {
			errorMessage = "Error while deleting a room"
		}
	}
}
