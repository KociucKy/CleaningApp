import Foundation
import UserDefaultsKit

// MARK: - OnboardingInteractor

@MainActor
struct OnboardingInteractor {
	// MARK: - Properties

	private let appState: OnboardingState
	private let flowState: OnboardingFlowState
	private let roomManager: RoomManager
	private let roomTaskManager: RoomTaskManager
	private let notificationScheduler: any NotificationScheduling

	// MARK: - Init

	init(container: DependencyContainer) {
		appState = container.resolve(OnboardingState.self)!
		flowState = container.resolve(OnboardingFlowState.self)!
		roomManager = container.resolve(RoomManager.self)!
		roomTaskManager = container.resolve(RoomTaskManager.self)!
		notificationScheduler = container.resolve(NotificationScheduling.self)!
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

	// MARK: - Flow State — Custom Rooms

	var customRooms: [CustomRoomSelection] {
		flowState.customRooms
	}

	func addCustomRoom(name: String, icon: String) {
		flowState.addCustomRoom(name: name, icon: icon)
	}

	func toggleCustomRoom(id: UUID) {
		flowState.toggleCustomRoom(id: id)
	}

	func isCustomRoomSelected(id: UUID) -> Bool {
		flowState.isCustomRoomSelected(id: id)
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

	var selectedRoomsCount: Int {
		flowState.selectedRooms.count + flowState.selectedCustomRooms().count
	}

	var selectedTasksCount: Int {
		let predefinedRoomTasks = flowState.selectedTasks.values.reduce(0) { $0 + $1.count }
		let customRoomTasks = flowState.selectedCustomRooms().reduce(0) { $0 + $1.selectedTaskIds.count }
		return predefinedRoomTasks + customRoomTasks
	}

	// MARK: - Flow State — Custom Tasks

	func allTasks(for room: RoomType) -> [RoomTask] {
		flowState.allTasks(for: room)
	}

	func isCustomTask(_ task: RoomTask, for room: RoomType) -> Bool {
		flowState.isCustomTask(task, for: room)
	}

	func addCustomTask(_ task: RoomTask, for room: RoomType) {
		flowState.addCustomTask(task, for: room)
	}

	func removeCustomTask(_ task: RoomTask, for room: RoomType) {
		flowState.removeCustomTask(task, for: room)
	}

	// MARK: - Flow State — Custom Room Tasks

	func selectedCustomRooms() -> [CustomRoomSelection] {
		flowState.selectedCustomRooms()
	}

	func addTaskToCustomRoom(_ task: RoomTask, roomId: UUID) {
		flowState.addTaskToCustomRoom(task, roomId: roomId)
	}

	func removeTaskFromCustomRoom(_ task: RoomTask, roomId: UUID) {
		flowState.removeTaskFromCustomRoom(task, roomId: roomId)
	}

	func toggleCustomRoomTask(_ task: RoomTask, roomId: UUID) {
		flowState.toggleCustomRoomTask(task, roomId: roomId)
	}

	func isCustomRoomTaskSelected(_ task: RoomTask, roomId: UUID) -> Bool {
		flowState.isCustomRoomTaskSelected(task, roomId: roomId)
	}

	func customRoomTasks(roomId: UUID) -> [RoomTask] {
		flowState.customRoomTasks(roomId: roomId)
	}

	// MARK: - Flow State — Notifications

	func setNotificationsAllowed(_ allowed: Bool) {
		flowState.notificationsAllowed = allowed
	}

	var notificationsAllowed: Bool {
		flowState.notificationsAllowed
	}

	func saveNotificationTime(_ time: Date) {
		UserDefaultsStore.standard.set(time, for: .notificationTime)
	}

	func scheduleInitialNotification(at time: Date) {
		guard flowState.notificationsAllowed else { return }

		do {
			try notificationScheduler.scheduleDailyReminder(at: time)
		} catch {
			// Log error but don't block onboarding completion
			print("Failed to schedule notification: \(error)")
		}
	}

	// MARK: - Persistence

	/// Saves all selected rooms and their tasks to SwiftData, then marks
	/// onboarding as complete. On save failure, onboarding still completes
	/// to avoid leaving the user stranded.
	func saveAndCompleteOnboarding() {
		do {
			// 1. Save predefined rooms first — tasks depend on their IDs existing in the store.
			var savedRooms: [Room] = []
			for roomType in flowState.selectedRooms {
				let room = Room(name: roomType.rawValue, kind: roomType)
				try roomManager.save(room)
				savedRooms.append(room)
			}

			// 2. Save custom rooms with isCustom flag and custom icon
			for customRoom in flowState.customRooms where customRoom.isSelected {
				let room = Room(
					id: customRoom.id,
					name: customRoom.name,
					kind: .customRoom,
					isCustom: true,
					customIcon: customRoom.icon
				)
				try roomManager.save(room)
				savedRooms.append(room)
			}

			// 3. Save selected tasks for all rooms, substituting the real roomId.
			for savedRoom in savedRooms {
				let tasks: [RoomTask] = if savedRoom.isCustom {
					// For custom rooms, get tasks from the custom room's selectedTasks
					flowState.customRooms.first(where: { $0.id == savedRoom.id })?.selectedTasks ?? []
				} else {
					// For predefined rooms, get all selected tasks (suggested + custom)
					flowState.selectedTasks[savedRoom.kind] ?? []
				}
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
