import Foundation

// MARK: - OnboardingFlowState

/// Holds the user's selections across the onboarding flow.
/// Lives for the duration of onboarding and is the single source of truth
/// for what will be persisted when the flow completes.
@Observable
@MainActor
final class OnboardingFlowState {
	// MARK: - Properties

	/// Rooms the user selected, in selection order.
	private(set) var selectedRooms: [RoomType] = []

	/// Tasks selected per room. Keyed by `RoomType`; values contain all
	/// selected tasks for that room (both suggested tasks the user opted in to,
	/// and custom tasks which are auto-selected when created).
	private(set) var selectedTasks: [RoomType: [RoomTask]] = [:]

	/// Custom rooms created by the user during onboarding, in creation order.
	private(set) var customRooms: [CustomRoomSelection] = []

	/// Custom tasks created by the user for predefined rooms during onboarding.
	/// Keyed by `RoomType`; values are user-created tasks for that room.
	/// Note: Custom tasks are automatically added to `selectedTasks` when created.
	private(set) var customTasks: [RoomType: [RoomTask]] = [:]

	// MARK: - Room Selection

	func toggleRoom(_ room: RoomType) {
		if let index = selectedRooms.firstIndex(of: room) {
			selectedRooms.remove(at: index)
			selectedTasks.removeValue(forKey: room)
		} else {
			selectedRooms.append(room)
			selectedTasks[room] = Array(room.suggestedTasks.prefix(3))
		}
	}

	func clearRooms() {
		selectedRooms = []
		selectedTasks = [:]
		// Deselect all custom rooms instead of removing them
		for index in customRooms.indices {
			customRooms[index].isSelected = false
		}
	}

	func isRoomSelected(_ room: RoomType) -> Bool {
		selectedRooms.contains(room)
	}

	// MARK: - Custom Room Management

	func addCustomRoom(name: String, icon: String) {
		let customRoom = CustomRoomSelection(name: name, icon: icon)
		customRooms.append(customRoom)
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
		if let index = tasks.firstIndex(of: task) {
			tasks.remove(at: index)
		} else {
			tasks.append(task)
		}
		selectedTasks[room] = tasks
	}

	func isTaskSelected(_ task: RoomTask, for room: RoomType) -> Bool {
		selectedTasks[room]?.contains(task) ?? false
	}

	// MARK: - Custom Task Management

	/// Adds a custom task to the specified room and automatically selects it.
	func addCustomTask(_ task: RoomTask, for room: RoomType) {
		var tasks = customTasks[room] ?? []
		tasks.append(task)
		customTasks[room] = tasks

		// Auto-select the newly created custom task
		var selected = selectedTasks[room] ?? []
		selected.append(task)
		selectedTasks[room] = selected
	}

	/// Removes a custom task from the specified room and deselects it.
	func removeCustomTask(_ task: RoomTask, for room: RoomType) {
		var tasks = customTasks[room] ?? []
		tasks.removeAll { $0.id == task.id }
		customTasks[room] = tasks.isEmpty ? nil : tasks

		// Also remove from selected tasks
		var selected = selectedTasks[room] ?? []
		selected.removeAll { $0.id == task.id }
		selectedTasks[room] = selected
	}

	/// Returns all tasks for a room: suggested + custom.
	func allTasks(for room: RoomType) -> [RoomTask] {
		let suggested = room.suggestedTasks
		let custom = customTasks[room] ?? []
		return suggested + custom
	}

	/// Returns only custom tasks for a room.
	func customTasksOnly(for room: RoomType) -> [RoomTask] {
		customTasks[room] ?? []
	}

	/// Checks if a task is custom (not in suggested tasks).
	func isCustomTask(_ task: RoomTask, for room: RoomType) -> Bool {
		!room.suggestedTasks.contains(task)
	}

	// MARK: - Custom Room Task Management

	/// Returns selected custom rooms (custom rooms where isSelected == true).
	func selectedCustomRooms() -> [CustomRoomSelection] {
		customRooms.filter(\.isSelected)
	}

	/// Adds a task to a custom room's allTasks and marks it as selected.
	func addTaskToCustomRoom(_ task: RoomTask, roomId: UUID) {
		if let index = customRooms.firstIndex(where: { $0.id == roomId }) {
			customRooms[index].allTasks.append(task)
			customRooms[index].selectedTaskIds.insert(task.id)
		}
	}

	/// Removes a task entirely from a custom room (deletes it from allTasks).
	func removeTaskFromCustomRoom(_ task: RoomTask, roomId: UUID) {
		if let index = customRooms.firstIndex(where: { $0.id == roomId }) {
			customRooms[index].allTasks.removeAll { $0.id == task.id }
			customRooms[index].selectedTaskIds.remove(task.id)
		}
	}

	/// Toggles a task's selection state in a custom room (does not remove from allTasks).
	func toggleCustomRoomTask(_ task: RoomTask, roomId: UUID) {
		if let roomIndex = customRooms.firstIndex(where: { $0.id == roomId }) {
			if customRooms[roomIndex].selectedTaskIds.contains(task.id) {
				customRooms[roomIndex].selectedTaskIds.remove(task.id)
			} else {
				customRooms[roomIndex].selectedTaskIds.insert(task.id)
			}
		}
	}

	/// Checks if a task is selected in a custom room.
	func isCustomRoomTaskSelected(_ task: RoomTask, roomId: UUID) -> Bool {
		customRooms.first(where: { $0.id == roomId })?.selectedTaskIds.contains(task.id) ?? false
	}

	/// Returns all tasks for a custom room.
	func customRoomTasks(roomId: UUID) -> [RoomTask] {
		customRooms.first(where: { $0.id == roomId })?.allTasks ?? []
	}
}
