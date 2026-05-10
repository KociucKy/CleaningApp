import SwiftUI

// MARK: - OnbTaskSelectionPresenter

@Observable
@MainActor
final class OnbTaskSelectionPresenter {
	// MARK: - Properties

	private let interactor: OnboardingInteractor
	private let router: OnboardingRouter

	var buttonVisible = false
	var visibleSectionCount = 0
	private var entranceAnimationIndex = 0

	var selectedRooms: [RoomType] {
		interactor.selectedRooms
	}

	var selectedCustomRooms: [CustomRoomSelection] {
		interactor.selectedCustomRooms()
	}

	// MARK: - Init

	init(
		interactor: OnboardingInteractor,
		router: OnboardingRouter
	) {
		self.interactor = interactor
		self.router = router
	}

	// MARK: - Actions

	func animateEntrance() {
		let count = interactor.selectedRooms.count + interactor.selectedCustomRooms().count
		Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] timer in
			guard let self else {
				timer.invalidate()
				return
			}
			withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
				visibleSectionCount = entranceAnimationIndex + 1
			}
			entranceAnimationIndex += 1
			if entranceAnimationIndex >= count {
				timer.invalidate()
				withAnimation(.easeOut(duration: 0.35)) {
					buttonVisible = true
				}
			}
		}
	}

	func onNextButtonPressed() {
		router.showOnboardingNotificationView()
	}

	func onSkipButtonPressed() {
		router.showOnboardingNotificationView()
	}

	func onAddCustomTaskButtonPressed(for room: RoomType) {
		router.presentCustomTaskSheet(for: room)
	}

	func onAddCustomTaskButtonPressed(for customRoom: CustomRoomSelection) {
		router.presentCustomTaskSheet(for: customRoom)
	}

	// MARK: - Methods

	func suggestedTasks(for room: RoomType) -> [RoomTask] {
		interactor.suggestedTasks(for: room)
	}

	func isTaskSelected(_ task: RoomTask, for room: RoomType) -> Bool {
		interactor.isTaskSelected(task, for: room)
	}

	func selectedTaskCount(for room: RoomType) -> Int {
		interactor.selectedTasks(for: room).count
	}

	func onTaskRowPressed(_ task: RoomTask, for room: RoomType) {
		interactor.toggleTask(task, for: room)
	}

	// MARK: - Custom Tasks

	/// Returns all tasks for a room: suggested + custom.
	func allTasks(for room: RoomType) -> [RoomTask] {
		interactor.allTasks(for: room)
	}

	/// Checks if a task is custom (not in suggested tasks).
	func isCustomTask(_ task: RoomTask, for room: RoomType) -> Bool {
		interactor.isCustomTask(task, for: room)
	}

	/// Removes a custom task from the specified room.
	func onDeleteCustomTask(_ task: RoomTask, for room: RoomType) {
		interactor.removeCustomTask(task, for: room)
	}

	// MARK: - Custom Rooms

	func customRoomTasks(_ customRoom: CustomRoomSelection) -> [RoomTask] {
		interactor.customRoomTasks(roomId: customRoom.id)
	}

	func isCustomRoomTaskSelected(_ task: RoomTask, in customRoom: CustomRoomSelection) -> Bool {
		interactor.isCustomRoomTaskSelected(task, roomId: customRoom.id)
	}

	func selectedCustomRoomTaskCount(_ customRoom: CustomRoomSelection) -> Int {
		interactor.customRoomTasks(roomId: customRoom.id).count
	}

	func onCustomRoomTaskRowPressed(_ task: RoomTask, in customRoom: CustomRoomSelection) {
		interactor.toggleCustomRoomTask(task, roomId: customRoom.id)
	}

	func onDeleteCustomRoomTask(_ task: RoomTask, from customRoom: CustomRoomSelection) {
		interactor.removeTaskFromCustomRoom(task, roomId: customRoom.id)
	}
}
