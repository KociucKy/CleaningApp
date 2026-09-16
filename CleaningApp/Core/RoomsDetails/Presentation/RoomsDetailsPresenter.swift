import FulhamKit
import SwiftUI

// MARK: - RoomsDetailsPresenter

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
	private(set) var completionTrendRange: CompletionTrendRange = .sevenDays
	private(set) var isLoading = true
	private var completedTasks: [CompletedTask] = []
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

	var hasAnyCompletions: Bool {
		!completedTasks.isEmpty
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
			let completedTasks = try tasks.flatMap { task in
				try interactor.fetchAllCompletedTasks(for: task.id)
			}
			self.completedTasks = completedTasks
			completedTaskIDs = Set(completedTasks.map(\.taskId))
			completionTrend = interactor.makeCompletionTrend(
				from: completedTasks,
				tasks: tasks,
				range: completionTrendRange
			)
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
			buttons: { @MainActor [weak self] in
				Group {
					Button("Yes", role: .destructive) {
						FKHaptics.notification(.warning)
						self?.deleteTask(task, roomId: roomId)
					}
					Button("Cancel", role: .cancel) {
						self?.router.dismissAlert()
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
		router.presentCustomTaskSheet(roomId: roomId, task: nil) { [weak self] _ in
			guard let self else { return }
			withAnimation {
				self.reloadTasks(for: roomId)
			}
		}
	}

	func onEditRoomButtonTapped() {
		router.presentCustomRoomSheet(room: room) { [weak self] updatedRoom in
			self?.room = updatedRoom
		}
	}

	func onIconButtonTapped() {
		router.presentIconPicker(room: room) { [self] updatedRoom in
			room = updatedRoom
		}
	}

	func onDeleteRoomButtonTapped() {
		router.showAlert(
			.alert,
			title: "Are you sure you want to delete \(room.name)",
			subtitle: nil,
			buttons: { @MainActor [weak self] in
				Group {
					Button("Yes", role: .destructive) {
						FKHaptics.notification(.warning)
						self?.deleteRoom()
					}
					Button("Cancel", role: .cancel) {
						self?.router.dismissAlert()
					}
				}.any()
			}
		)
	}

	func onCompletionTrendRangeChanged(_ range: CompletionTrendRange) {
		guard completionTrendRange != range else {
			return
		}

		completionTrendRange = range
		completionTrend = interactor.makeCompletionTrend(
			from: completedTasks,
			tasks: tasks,
			range: range
		)
	}

	func onTaskCompletionTapped(_ task: RoomTask) {
		router.presentRoomsDetailsTaskCompletionSheet(
			props: RoomsDetailsTaskCompletionProps(
				taskId: task.id,
				taskName: task.name
			),
			onDismiss: { [weak self] in
				guard let self else {
					return
				}

				withAnimation {
					self.reloadTasks(for: self.room.id)
				}
			}
		)
	}

	func onEditTaskButtonTapped(_ task: RoomTask) {
		router.presentCustomTaskSheet(roomId: room.id, task: task) { [weak self] _ in
			DispatchQueue.main.async {
				guard let self else { return }
				withAnimation {
					self.reloadTasks(for: self.room.id)
				}
			}
		}
	}

	// MARK: - Private

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
