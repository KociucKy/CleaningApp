import Foundation
import Testing
@testable import CleaningApp

// MARK: - OnboardingFlowStateTests

@Suite(.tags(.onboarding))
@MainActor
struct OnboardingFlowStateTests {
	// MARK: - toggleRoom (selection)

	@Test(.tags(.adding)) func toggleRoom_addsRoomToSelectedRooms() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		#expect(state.selectedRooms == [.kitchen])
	}

	@Test(.tags(.adding)) func toggleRoom_preservesSelectionOrder() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		state.toggleRoom(.bedroom)
		state.toggleRoom(.bathroom)
		#expect(state.selectedRooms == [.kitchen, .bedroom, .bathroom])
	}

	@Test(.tags(.deleting)) func toggleRoom_removesAlreadySelectedRoom() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		state.toggleRoom(.kitchen)
		#expect(state.selectedRooms.isEmpty)
	}

	@Test(.tags(.deleting)) func toggleRoom_removesTasksWhenRoomDeselected() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		state.toggleRoom(.kitchen)
		#expect(state.selectedTasks[.kitchen] == nil)
	}

	// MARK: - toggleRoom (task pre-population)

	@Test(.tags(.adding)) func toggleRoom_prePopulatesUpToThreeSuggestedTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let tasks = state.selectedTasks[.kitchen] ?? []
		#expect(tasks.count <= 3)
		#expect(!tasks.isEmpty)
	}

	@Test(.tags(.adding)) func toggleRoom_prePopulatedTasksAreSubsetOfSuggestedTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let prePopulated = state.selectedTasks[.kitchen] ?? []
		let suggested = RoomType.kitchen.suggestedTasks
		for task in prePopulated {
			#expect(suggested.contains(task))
		}
	}

	// MARK: - isRoomSelected

	@Test func isRoomSelected_returnsTrueAfterToggleOn() {
		let state = OnboardingFlowState()
		state.toggleRoom(.bedroom)
		#expect(state.isRoomSelected(.bedroom))
	}

	@Test func isRoomSelected_returnsFalseAfterToggleOff() {
		let state = OnboardingFlowState()
		state.toggleRoom(.bedroom)
		state.toggleRoom(.bedroom)
		#expect(!state.isRoomSelected(.bedroom))
	}

	@Test func isRoomSelected_returnsFalseForUnselectedRoom() {
		let state = OnboardingFlowState()
		#expect(!state.isRoomSelected(.kitchen))
	}

	// MARK: - clearRooms

	@Test(.tags(.deleting)) func clearRooms_removesAllSelectedRooms() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		state.toggleRoom(.bedroom)
		state.clearRooms()
		#expect(state.selectedRooms.isEmpty)
	}

	@Test(.tags(.deleting)) func clearRooms_removesAllSelectedTasks() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		state.toggleRoom(.bedroom)
		state.clearRooms()
		#expect(state.selectedTasks.isEmpty)
	}

	// MARK: - toggleTask

	@Test(.tags(.adding)) func toggleTask_addsTaskForRoom() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		// Use a task outside the pre-populated set (prefix(3) = indices 0,1,2)
		let allTasks = RoomType.kitchen.suggestedTasks
		let prePopulated = state.selectedTasks[.kitchen] ?? []
		guard let unpopulatedTask = allTasks.first(where: { !prePopulated.contains($0) }) else {
			Issue.record("Kitchen has no unpopulated tasks to test")
			return
		}
		let initialCount = prePopulated.count
		state.toggleTask(unpopulatedTask, for: .kitchen)
		#expect((state.selectedTasks[.kitchen]?.count ?? 0) == initialCount + 1)
	}

	@Test(.tags(.deleting)) func toggleTask_removesAlreadySelectedTask() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		let task = RoomType.kitchen.suggestedTasks[0]
		// Ensure selected, then deselect
		if !state.isTaskSelected(task, for: .kitchen) {
			state.toggleTask(task, for: .kitchen)
		}
		state.toggleTask(task, for: .kitchen)
		#expect(state.isTaskSelected(task, for: .kitchen) == false)
	}

	// MARK: - isTaskSelected

	@Test func isTaskSelected_returnsFalseForUnselectedTask() {
		let state = OnboardingFlowState()
		state.toggleRoom(.kitchen)
		// Use a task that is not in the first 3 pre-populated tasks
		let allTasks = RoomType.kitchen.suggestedTasks
		let prePopulated = state.selectedTasks[.kitchen] ?? []
		guard let unpopulatedTask = allTasks.first(where: { !prePopulated.contains($0) }) else { return }
		#expect(!state.isTaskSelected(unpopulatedTask, for: .kitchen))
	}

	@Test func isTaskSelected_returnsFalseForUnselectedRoom() {
		let state = OnboardingFlowState()
		let task = RoomType.kitchen.suggestedTasks[0]
		#expect(!state.isTaskSelected(task, for: .kitchen))
	}
}
