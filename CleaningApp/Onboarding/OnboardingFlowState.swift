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

	/// Tasks selected per room. Keyed by `RoomType`; values are the
	/// subset of that room's suggested tasks the user opted in to.
	private(set) var selectedTasks: [RoomType: [RoomTask]] = [:]

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
	}

	func isRoomSelected(_ room: RoomType) -> Bool {
		selectedRooms.contains(room)
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
}
