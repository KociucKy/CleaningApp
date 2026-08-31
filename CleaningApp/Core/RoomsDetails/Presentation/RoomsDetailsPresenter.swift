import SwiftUI

@Observable
@MainActor
final class RoomsDetailsPresenter {
	// MARK: - Properties

	private let interactor: any RoomsDetailsInteractor
	private let router: any RoomsDetailsRouter

	private(set) var tasks: [RoomTask] = []
	private(set) var frequencies: [Frequency] = []
	private(set) var tasksByFrequency: [Frequency: [RoomTask]] = [:]
	private(set) var completedTaskIDs: Set<UUID> = []
	private(set) var isLoading = true
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
		router: any RoomsDetailsRouter
	) {
		self.interactor = interactor
		self.router = router
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
			completedTaskIDs = try Set(
				tasks.flatMap { task in
					try interactor.fetchAllCompletedTasks(for: task.id)
				}.map(\.taskId)
			)
		} catch {
			errorMessage = "Unable to load this room’s tasks."
		}

		isLoading = false
	}

	func onDeleteTaskButtonTapped(_ task: RoomTask, roomId: UUID) {
		do {
			try interactor.deleteRoomTask(task)
			withAnimation {
				reloadTasks(for: roomId)
			}
		} catch {
			errorMessage = "Unable to delete this task."
		}
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
		router.presentAddCustomTaskSheet(roomId: roomId) { [weak self] in
			guard let self else { return }
			self.reloadTasks(for: roomId)
		}
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
		
	}
}
