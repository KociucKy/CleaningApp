import Foundation

// MARK: - OnboardingInteractor

@MainActor
struct OnboardingInteractor {
	// MARK: - Properties

	private let appState: OnboardingState
	private let flowState: OnboardingFlowState
	private let roomManager: RoomManager
	private let roomTaskManager: RoomTaskManager

	// MARK: - Init

	init(container: DependencyContainer) {
		appState = container.resolve(OnboardingState.self)!
		flowState = container.resolve(OnboardingFlowState.self)!
		roomManager = container.resolve(RoomManager.self)!
		roomTaskManager = container.resolve(RoomTaskManager.self)!
	}

	// MARK: - Flow State — Rooms

	var selectedRooms: [RoomIcon] {
		flowState.selectedRooms
	}

	func toggleRoom(_ room: RoomIcon) {
		flowState.toggleRoom(room)
	}

	func clearRooms() {
		flowState.clearRooms()
	}

	func isRoomSelected(_ room: RoomIcon) -> Bool {
		flowState.isRoomSelected(room)
	}

	// MARK: - Flow State — Tasks

	func suggestedTasks(for room: RoomIcon) -> [RoomTask] {
		room.suggestedTasks
	}

	func toggleTask(_ task: RoomTask, for room: RoomIcon) {
		flowState.toggleTask(task, for: room)
	}

	func isTaskSelected(_ task: RoomTask, for room: RoomIcon) -> Bool {
		flowState.isTaskSelected(task, for: room)
	}

	func selectedTasks(for room: RoomIcon) -> [RoomTask] {
		flowState.selectedTasks[room] ?? []
	}

	// MARK: - Persistence

	/// Saves all selected rooms and their tasks to SwiftData, then marks
	/// onboarding as complete. On save failure, onboarding still completes
	/// to avoid leaving the user stranded.
	func saveAndCompleteOnboarding() {
		do {
			// 1. Save rooms first — tasks depend on their IDs existing in the store.
			var savedRooms: [Room] = []
			for icon in flowState.selectedRooms {
				let room = Room(name: icon.rawValue, icon: icon)
				try roomManager.save(room)
				savedRooms.append(room)
			}

			// 2. Save selected tasks, substituting the real roomId.
			for savedRoom in savedRooms {
				let tasks = flowState.selectedTasks[savedRoom.icon] ?? []
				for task in tasks {
					var taskToSave = task
					taskToSave.roomId = savedRoom.id
					try roomTaskManager.save(taskToSave)
				}
			}
		} catch {
			// Data loss is preferable to leaving the user stuck in onboarding.
		}

		completeOnboarding()
	}

	// MARK: - App State

	func completeOnboarding() {
		appState.updateViewState(showOnboarding: false)
	}
}
