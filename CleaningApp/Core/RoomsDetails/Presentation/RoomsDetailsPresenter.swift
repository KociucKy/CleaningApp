import Foundation

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

    var completedTaskCount: Int {
        tasks.filter { completedTaskIDs.contains($0.id) }.count
    }

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

    func onAppear(room: Room) {
        guard isLoading else {
            return
        }

        do {
            tasks = try interactor.fetchRoomTasks(for: room.id).sorted { $0.name < $1.name }
            var seenFrequencies = Set<Frequency>()
            frequencies = tasks.compactMap { task in
                seenFrequencies.insert(task.frequency).inserted ? task.frequency : nil
            }
            tasksByFrequency = Dictionary(grouping: tasks, by: \.frequency)
            completedTaskIDs = try Set(
                tasks.flatMap { task in
                    try interactor.fetchCompletedTasks(for: task.id)
                }.map(\.taskId)
            )
        } catch {
            errorMessage = "Unable to load this room’s tasks."
        }

        isLoading = false
    }

    func onTaskCompletionTapped(_ task: RoomTask) {
        do {
            if completedTaskIDs.contains(task.id) {
                let completedTasks = try interactor.fetchCompletedTasks(for: task.id)
                for completedTask in completedTasks {
                    try interactor.deleteCompletedTask(completedTask)
                }
                completedTaskIDs.remove(task.id)
            } else {
                try interactor.saveCompletedTask(CompletedTask(taskId: task.id))
                completedTaskIDs.insert(task.id)
            }
        } catch {
            errorMessage = "Unable to update this task."
        }
    }
}
