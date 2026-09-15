import Foundation
import SwiftUI

// MARK: - OnbAddCustomTaskSheetPresenter

@Observable
@MainActor
final class OnbAddCustomTaskSheetPresenter {
    // MARK: - Properties

    private let interactor: OnboardingInteractor
    private let router: OnboardingRouter
    private let roomType: RoomType?
    private let customRoomId: UUID?
    private let task: RoomTask?

    var taskName = ""
    var selectedFrequency: Frequency = .timesPerWeek(1)
    var selectedDuration: TaskDuration = .fiveMinutes

    var isEditing: Bool {
        task != nil
    }

    var isTaskNameValid: Bool {
        !taskName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Init

    init(
        interactor: OnboardingInteractor,
        router: OnboardingRouter,
        roomType: RoomType
    ) {
        self.interactor = interactor
        self.router = router
        self.roomType = roomType
        customRoomId = nil
        task = nil
    }

    init(
        interactor: OnboardingInteractor,
        router: OnboardingRouter,
        customRoomId: UUID
    ) {
        self.interactor = interactor
        self.router = router
        roomType = nil
        self.customRoomId = customRoomId
        task = nil
    }

    init(
        interactor: OnboardingInteractor,
        router: OnboardingRouter,
        roomType: RoomType,
        task: RoomTask
    ) {
        self.interactor = interactor
        self.router = router
        self.roomType = roomType
        customRoomId = nil
        self.task = task
        taskName = task.name
        selectedFrequency = task.frequency.canonicalized
        selectedDuration = task.estimatedDuration
    }

    init(
        interactor: OnboardingInteractor,
        router: OnboardingRouter,
        customRoomId: UUID,
        task: RoomTask
    ) {
        self.interactor = interactor
        self.router = router
        roomType = nil
        self.customRoomId = customRoomId
        self.task = task
        taskName = task.name
        selectedFrequency = task.frequency.canonicalized
        selectedDuration = task.estimatedDuration
    }

    // MARK: - Actions

    func onCancelButtonPressed() {
        router.dismissScreen()
    }

    func onAddButtonPressed() {
        guard isTaskNameValid else {
            return
        }

        let updatedTask = RoomTask(
            id: task?.id ?? UUID(),
            name: taskName.trimmingCharacters(in: .whitespaces),
            roomId: task?.roomId ?? UUID(),
            frequency: selectedFrequency,
            estimatedDuration: selectedDuration,
            createdAt: task?.createdAt ?? Date()
        )

        if let roomType {
            if task == nil {
                interactor.addCustomTask(updatedTask, for: roomType)
            } else {
                interactor.updateTask(updatedTask, for: roomType)
            }
        } else if let customRoomId {
            if task == nil {
                interactor.addTaskToCustomRoom(updatedTask, roomId: customRoomId)
            } else {
                interactor.updateTask(updatedTask, inCustomRoom: customRoomId)
            }
        }

        router.dismissScreen()
    }
}
