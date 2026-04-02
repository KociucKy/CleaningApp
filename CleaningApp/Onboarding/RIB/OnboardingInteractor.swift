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

	var selectedRooms: [RoomType] {
		flowState.selectedRooms
	}

	func toggleRoom(_ room: RoomType) {
		flowState.toggleRoom(room)
	}

	func clearRooms() {
		flowState.clearRooms()
	}

	func isRoomSelected(_ room: RoomType) -> Bool {
		flowState.isRoomSelected(room)
	}

	// MARK: - Flow State — Tasks

	func suggestedTasks(for room: RoomType) -> [RoomTask] {
		room.suggestedTasks
	}

	func toggleTask(_ task: RoomTask, for room: RoomType) {
		flowState.toggleTask(task, for: room)
	}

	func isTaskSelected(_ task: RoomTask, for room: RoomType) -> Bool {
		flowState.isTaskSelected(task, for: room)
	}

	func selectedTasks(for room: RoomType) -> [RoomTask] {
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
			for roomType in flowState.selectedRooms {
				let room = Room(name: roomType.rawValue, kind: roomType)
				try roomManager.save(room)
				savedRooms.append(room)
			}

			// 2. Save selected tasks, substituting the real roomId.
			for savedRoom in savedRooms {
				let tasks = flowState.selectedTasks[savedRoom.kind] ?? []
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
