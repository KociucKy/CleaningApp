import Foundation
import Testing
@testable import CleaningApp

// MARK: - OnboardingFlowStateCustomTaskTests

/// Tests for custom task functionality in OnboardingFlowState.
/// Split from main test suite due to type body length limit.
@Suite(.tags(.onboarding))
@MainActor
struct OnboardingFlowStateCustomTaskTests {
	// MARK: - addCustomTask

	@Test(.tags(.adding)) func addCustomTask_addsToCustomTasksCollection() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		#expect(state.customTasks[.kitchen]?.contains(customTask) == true)
	}

	@Test(.tags(.adding)) func addCustomTask_autoSelectsNewTask() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		#expect(state.isTaskSelected(customTask, for: .kitchen))
	}

	@Test(.tags(.adding)) func addCustomTask_preservesExistingCustomTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let task1 = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		let task2 = RoomTask(
			name: "Organize pantry",
			roomId: UUID(),
			frequency: .monthly,
			estimatedDuration: .minutes30
		)
		state.addCustomTask(task1, for: .kitchen)
		state.addCustomTask(task2, for: .kitchen)
		#expect(state.customTasks[.kitchen]?.count == 2)
		#expect(state.customTasks[.kitchen]?.contains(task1) == true)
		#expect(state.customTasks[.kitchen]?.contains(task2) == true)
	}

	// MARK: - removeCustomTask

	@Test(.tags(.deleting)) func removeCustomTask_removesFromCustomTasksCollection() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		state.removeCustomTask(customTask, for: .kitchen)
		#expect(state.customTasks[.kitchen] == nil)
	}

	@Test(.tags(.deleting)) func removeCustomTask_deselectsTask() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		state.removeCustomTask(customTask, for: .kitchen)
		#expect(!state.isTaskSelected(customTask, for: .kitchen))
	}

	@Test(.tags(.deleting)) func removeCustomTask_preservesOtherCustomTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let task1 = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		let task2 = RoomTask(
			name: "Organize pantry",
			roomId: UUID(),
			frequency: .monthly,
			estimatedDuration: .minutes30
		)
		state.addCustomTask(task1, for: .kitchen)
		state.addCustomTask(task2, for: .kitchen)
		state.removeCustomTask(task1, for: .kitchen)
		#expect(state.customTasks[.kitchen]?.count == 1)
		#expect(state.customTasks[.kitchen]?.contains(task2) == true)
		#expect(state.isTaskSelected(task2, for: .kitchen))
	}

	// MARK: - allTasks

	@Test func allTasks_includesSuggestedTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let allTasks = state.allTasks(for: .kitchen)
		let suggestedTasks = RoomType.kitchen.suggestedTasks
		for suggestedTask in suggestedTasks {
			#expect(allTasks.contains(suggestedTask))
		}
	}

	@Test func allTasks_includesCustomTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		let allTasks = state.allTasks(for: .kitchen)
		#expect(allTasks.contains(customTask))
	}

	@Test func allTasks_combinesSuggestedAndCustomTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		let allTasks = state.allTasks(for: .kitchen)
		let suggestedCount = RoomType.kitchen.suggestedTasks.count
		#expect(allTasks.count == suggestedCount + 1)
	}

	// MARK: - customTasksOnly

	@Test func customTasksOnly_returnsEmptyWhenNoCustomTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		#expect(state.customTasksOnly(for: .kitchen).isEmpty)
	}

	@Test func customTasksOnly_returnsOnlyCustomTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		let customOnly = state.customTasksOnly(for: .kitchen)
		#expect(customOnly.count == 1)
		#expect(customOnly.contains(customTask))
	}

	// MARK: - isCustomTask

	@Test func isCustomTask_returnsFalseForSuggestedTask() {
		let state = OnboardingFlowState()
		let suggestedTask = RoomType.kitchen.suggestedTasks[0]
		#expect(!state.isCustomTask(suggestedTask, for: .kitchen))
	}

	@Test func isCustomTask_returnsTrueForCustomTask() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let customTask = RoomTask(
			name: "Clean windows",
			roomId: UUID(),
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addCustomTask(customTask, for: .kitchen)
		#expect(state.isCustomTask(customTask, for: .kitchen))
	}

	// MARK: - addTaskToCustomRoom

	@Test(.tags(.adding)) func addTaskToCustomRoom_addsToAllTasks() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task, roomId: roomId)
		#expect(state.customRooms[0].allTasks.contains(task))
	}

	@Test(.tags(.adding)) func addTaskToCustomRoom_autoSelectsTask() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task, roomId: roomId)
		#expect(state.isCustomRoomTaskSelected(task, roomId: roomId))
	}

	// MARK: - removeTaskFromCustomRoom

	@Test(.tags(.deleting)) func removeTaskFromCustomRoom_removesFromAllTasks() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task, roomId: roomId)
		state.removeTaskFromCustomRoom(task, roomId: roomId)
		#expect(!state.customRooms[0].allTasks.contains(task))
	}

	@Test(.tags(.deleting)) func removeTaskFromCustomRoom_removesFromSelectedTaskIds() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task, roomId: roomId)
		state.removeTaskFromCustomRoom(task, roomId: roomId)
		#expect(!state.isCustomRoomTaskSelected(task, roomId: roomId))
	}

	// MARK: - toggleCustomRoomTask

	@Test func toggleCustomRoomTask_deselectsSelectedTask() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task, roomId: roomId)
		state.toggleCustomRoomTask(task, roomId: roomId)
		#expect(!state.isCustomRoomTaskSelected(task, roomId: roomId))
	}

	@Test func toggleCustomRoomTask_selectsUnselectedTask() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task, roomId: roomId)
		state.toggleCustomRoomTask(task, roomId: roomId)
		state.toggleCustomRoomTask(task, roomId: roomId)
		#expect(state.isCustomRoomTaskSelected(task, roomId: roomId))
	}

	@Test func toggleCustomRoomTask_keepsTaskInAllTasks() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task, roomId: roomId)
		state.toggleCustomRoomTask(task, roomId: roomId)
		#expect(state.customRooms[0].allTasks.contains(task))
	}

	// MARK: - customRoomTasks

	@Test func customRoomTasks_returnsAllTasksForRoom() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		let task1 = RoomTask(
			name: "Dust shelves",
			roomId: roomId,
			frequency: .weekly,
			estimatedDuration: .minutes15
		)
		let task2 = RoomTask(
			name: "Organize desk",
			roomId: roomId,
			frequency: .daily,
			estimatedDuration: .minutes15
		)
		state.addTaskToCustomRoom(task1, roomId: roomId)
		state.addTaskToCustomRoom(task2, roomId: roomId)
		let tasks = state.customRoomTasks(roomId: roomId)
		#expect(tasks.count == 2)
		#expect(tasks.contains(task1))
		#expect(tasks.contains(task2))
	}

	@Test func customRoomTasks_returnsEmptyForNonExistentRoom() {
		let state = OnboardingFlowState()
		let randomId = UUID()
		#expect(state.customRoomTasks(roomId: randomId).isEmpty)
	}

	// MARK: - selectedCustomRooms

	@Test func selectedCustomRooms_returnsOnlySelectedRooms() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		state.addCustomRoom(name: "Gym", icon: "dumbbell")
		let firstRoomId = state.customRooms[0].id
		state.toggleCustomRoom(id: firstRoomId)
		let selected = state.selectedCustomRooms()
		#expect(selected.count == 1)
		#expect(selected[0].name == "Gym")
	}

	@Test func selectedCustomRooms_returnsEmptyWhenAllDeselected() {
		let state = OnboardingFlowState()
		state.addCustomRoom(name: "Office", icon: "desktopcomputer")
		let roomId = state.customRooms[0].id
		state.toggleCustomRoom(id: roomId)
		#expect(state.selectedCustomRooms().isEmpty)
	}
}
