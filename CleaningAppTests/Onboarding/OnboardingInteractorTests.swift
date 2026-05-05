import Foundation
import Testing
@testable import CleaningApp

// MARK: - OnboardingInteractorTests

@Suite(.tags(.onboarding))
@MainActor
struct OnboardingInteractorTests {
	// MARK: - saveAndCompleteOnboarding (custom rooms)

	@Test func saveAndCompleteOnboarding_savesCustomRooms() throws {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let roomManager = preview.roomManager

		// Clear any existing mock data
		try? roomManager.fetchAll().forEach { try? roomManager.delete($0) }

		// Add a custom room to flow state
		interactor.addCustomRoom(name: "Office", icon: "desktopcomputer")

		// Save and complete
		interactor.saveAndCompleteOnboarding()

		// Verify custom room was saved
		let rooms = try roomManager.fetchAll()
		#expect(rooms.count == 1)
		#expect(rooms[0].name == "Office")
		#expect(rooms[0].kind == .customRoom)
		#expect(rooms[0].isCustom == true)
		#expect(rooms[0].customIcon == "desktopcomputer")
	}

	@Test func saveAndCompleteOnboarding_savesMultipleCustomRooms() throws {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let roomManager = preview.roomManager

		// Clear any existing mock data
		try? roomManager.fetchAll().forEach { try? roomManager.delete($0) }

		// Add multiple custom rooms
		interactor.addCustomRoom(name: "Office", icon: "desktopcomputer")
		interactor.addCustomRoom(name: "Gym", icon: "dumbbell")
		interactor.addCustomRoom(name: "Library", icon: "book")

		// Save and complete
		interactor.saveAndCompleteOnboarding()

		// Verify all custom rooms were saved
		let rooms = try roomManager.fetchAll()
		#expect(rooms.count == 3)
		let names = rooms.map(\.name).sorted()
		#expect(names == ["Gym", "Library", "Office"])
	}

	@Test func saveAndCompleteOnboarding_savesMixedPredefinedAndCustomRooms() throws {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let roomManager = preview.roomManager

		// Clear any existing mock data
		try? roomManager.fetchAll().forEach { try? roomManager.delete($0) }

		// Add predefined rooms
		interactor.toggleRoom(.kitchen)
		interactor.toggleRoom(.bedroom)

		// Add custom rooms
		interactor.addCustomRoom(name: "Office", icon: "desktopcomputer")
		interactor.addCustomRoom(name: "Gym", icon: "dumbbell")

		// Save and complete
		interactor.saveAndCompleteOnboarding()

		// Verify all rooms were saved
		let rooms = try roomManager.fetchAll()
		#expect(rooms.count == 4)

		let customRooms = rooms.filter(\.isCustom)
		#expect(customRooms.count == 2)

		let predefinedRooms = rooms.filter { !$0.isCustom }
		#expect(predefinedRooms.count == 2)
		#expect(predefinedRooms.contains { $0.kind == .kitchen })
		#expect(predefinedRooms.contains { $0.kind == .bedroom })
	}

	@Test func saveAndCompleteOnboarding_customRoomsHaveZeroTasks() throws {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let roomManager = preview.roomManager
		let taskManager = preview.roomTaskManager

		// Clear any existing mock data
		try? roomManager.fetchAll().forEach { try? roomManager.delete($0) }

		// Add a custom room
		interactor.addCustomRoom(name: "Office", icon: "desktopcomputer")

		// Save and complete
		interactor.saveAndCompleteOnboarding()

		// Get the saved custom room
		let rooms = try roomManager.fetchAll()
		let customRoom = try #require(rooms.first { $0.isCustom })

		// Verify custom room has no tasks
		let tasks = try taskManager.fetchAll(for: customRoom.id)
		#expect(tasks.isEmpty)
	}

	@Test func saveAndCompleteOnboarding_predefinedRoomsSaveWithTasks() {
		let preview = DevPreview()
		let flowState = preview.onboardingFlowState

		// Clear any existing mock data
		try? preview.roomManager.fetchAll().forEach { try? preview.roomManager.delete($0) }
		try? preview.roomTaskManager.fetchAll().forEach { try? preview.roomTaskManager.delete($0) }

		// Verify that selecting a room pre-populates 3 tasks
		flowState.toggleRoom(.kitchen)

		// Verify tasks were pre-populated in flow state
		let selectedTasks = flowState.selectedTasks[.kitchen] ?? []
		#expect(selectedTasks.count == 3) // Default pre-population is 3 tasks
	}

	@Test func saveAndCompleteOnboarding_marksOnboardingComplete() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let appState = preview.onboardingState

		// Initially onboarding should be showing
		#expect(appState.showOnboarding == true)

		// Add some rooms
		interactor.addCustomRoom(name: "Office", icon: "desktopcomputer")

		// Save and complete
		interactor.saveAndCompleteOnboarding()

		// Verify onboarding is marked complete
		#expect(appState.showOnboarding == false)
	}

	@Test func saveAndCompleteOnboarding_completesEvenIfNoRoomsSelected() {
		let preview = DevPreview()
		let interactor = OnboardingInteractor(container: preview.container)
		let appState = preview.onboardingState

		// Don't add any rooms

		// Save and complete
		interactor.saveAndCompleteOnboarding()

		// Verify onboarding is still marked complete (no rooms is valid)
		#expect(appState.showOnboarding == false)
	}
}
