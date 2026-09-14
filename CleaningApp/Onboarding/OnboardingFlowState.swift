import Foundation

// MARK: - OnboardingFlowState

@Observable
@MainActor
final class OnboardingFlowState {
    // MARK: - Properties

    private(set) var selectedRooms: [RoomType] = []
    private(set) var selectedTasks: [RoomType: [RoomTask]] = [:]
    private(set) var customRooms: [CustomRoomSelection] = []
    private(set) var customTasks: [RoomType: [RoomTask]] = [:]
    private var taskOverrides: [RoomType: [UUID: RoomTask]] = [:]
    var notificationsAllowed = false

    // MARK: - Room Selection

    func toggleRoom(_ room: RoomType) {
        if let index = selectedRooms.firstIndex(of: room) {
            selectedRooms.remove(at: index)
            selectedTasks.removeValue(forKey: room)
        } else {
            selectedRooms.append(room)
            selectedTasks[room] = room.suggestedTasks.map { overriddenTask($0, for: room) }.prefix(3).map { $0 }
        }
    }

    func clearRooms() {
        selectedRooms = []
        selectedTasks = [:]
        for index in customRooms.indices {
            customRooms[index].isSelected = false
        }
    }

    func isRoomSelected(_ room: RoomType) -> Bool {
        selectedRooms.contains(room)
    }

    // MARK: - Custom Room Management

    func addCustomRoom(name: String, icon: String) {
        customRooms.append(CustomRoomSelection(name: name, icon: icon))
    }

    func toggleCustomRoom(id: UUID) {
        if let index = customRooms.firstIndex(where: { $0.id == id }) {
            customRooms[index].isSelected.toggle()
        }
    }

    func removeCustomRoom(id: UUID) {
        customRooms.removeAll { $0.id == id }
    }

    func isCustomRoomSelected(id: UUID) -> Bool {
        customRooms.first(where: { $0.id == id })?.isSelected ?? false
    }

    // MARK: - Task Selection

    func toggleTask(_ task: RoomTask, for room: RoomType) {
        var tasks = selectedTasks[room] ?? []
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
        } else {
            tasks.append(task)
        }
        selectedTasks[room] = tasks
    }

    func isTaskSelected(_ task: RoomTask, for room: RoomType) -> Bool {
        selectedTasks[room]?.contains(where: { $0.id == task.id }) ?? false
    }

    // MARK: - Custom Task Management

    func addCustomTask(_ task: RoomTask, for room: RoomType) {
        var tasks = customTasks[room] ?? []
        tasks.append(task)
        customTasks[room] = tasks

        var selected = selectedTasks[room] ?? []
        selected.append(task)
        selectedTasks[room] = selected
    }

    func updateTask(_ task: RoomTask, for room: RoomType) {
        if let index = customTasks[room]?.firstIndex(where: { $0.id == task.id }) {
            customTasks[room]?[index] = task
        } else {
            taskOverrides[room, default: [:]][task.id] = task
        }
        replaceTask(task, in: &selectedTasks[room])
    }

    func removeCustomTask(_ task: RoomTask, for room: RoomType) {
        customTasks[room]?.removeAll { $0.id == task.id }
        if customTasks[room]?.isEmpty == true {
            customTasks.removeValue(forKey: room)
        }
        selectedTasks[room]?.removeAll { $0.id == task.id }
    }

    func allTasks(for room: RoomType) -> [RoomTask] {
        let suggested = room.suggestedTasks.map { overriddenTask($0, for: room) }
        return suggested + (customTasks[room] ?? [])
    }

    func customTasksOnly(for room: RoomType) -> [RoomTask] {
        customTasks[room] ?? []
    }

    func isCustomTask(_ task: RoomTask, for room: RoomType) -> Bool {
        !room.suggestedTasks.contains(where: { $0.id == task.id })
    }

    // MARK: - Custom Room Task Management

    func selectedCustomRooms() -> [CustomRoomSelection] {
        customRooms.filter(\.isSelected)
    }

    func addTaskToCustomRoom(_ task: RoomTask, roomId: UUID) {
        if let index = customRooms.firstIndex(where: { $0.id == roomId }) {
            customRooms[index].allTasks.append(task)
            customRooms[index].selectedTaskIds.insert(task.id)
        }
    }

    func updateTask(_ task: RoomTask, inCustomRoom roomId: UUID) {
        guard let index = customRooms.firstIndex(where: { $0.id == roomId }),
              let taskIndex = customRooms[index].allTasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        customRooms[index].allTasks[taskIndex] = task
    }

    func removeTaskFromCustomRoom(_ task: RoomTask, roomId: UUID) {
        if let index = customRooms.firstIndex(where: { $0.id == roomId }) {
            customRooms[index].allTasks.removeAll { $0.id == task.id }
            customRooms[index].selectedTaskIds.remove(task.id)
        }
    }

    func toggleCustomRoomTask(_ task: RoomTask, roomId: UUID) {
        if let roomIndex = customRooms.firstIndex(where: { $0.id == roomId }) {
            if customRooms[roomIndex].selectedTaskIds.contains(task.id) {
                customRooms[roomIndex].selectedTaskIds.remove(task.id)
            } else {
                customRooms[roomIndex].selectedTaskIds.insert(task.id)
            }
        }
    }

    func isCustomRoomTaskSelected(_ task: RoomTask, roomId: UUID) -> Bool {
        customRooms.first(where: { $0.id == roomId })?.selectedTaskIds.contains(task.id) ?? false
    }

    func customRoomTasks(roomId: UUID) -> [RoomTask] {
        customRooms.first(where: { $0.id == roomId })?.allTasks ?? []
    }

    // MARK: - Private

    private func overriddenTask(_ task: RoomTask, for room: RoomType) -> RoomTask {
        taskOverrides[room]?[task.id] ?? task
    }

    private func replaceTask(_ task: RoomTask, in tasks: inout [RoomTask]?) {
        guard let index = tasks?.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        tasks?[index] = task
    }
}
