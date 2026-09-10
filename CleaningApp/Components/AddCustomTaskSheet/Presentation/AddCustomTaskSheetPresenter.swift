import Foundation
import SwiftUI

// MARK: - AddCustomTaskSheetPresenter

@Observable
@MainActor
final class AddCustomTaskSheetPresenter {
    // MARK: - Properties

    private let interactor: any AddCustomTaskSheetInteractor
    private let router: any AddCustomTaskSheetRouter
    private let roomId: UUID
    private let task: RoomTask?
    private let onTaskSaved: (RoomTask) -> Void

    var taskName = ""
    var selectedFrequency: Frequency = .timesPerWeek(1)

    var isEditing: Bool {
        task != nil
    }

    var isTaskNameValid: Bool {
        !taskName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Init

    init(
        interactor: any AddCustomTaskSheetInteractor,
        router: any AddCustomTaskSheetRouter,
        roomId: UUID,
        task: RoomTask?,
        onTaskSaved: @escaping (RoomTask) -> Void
    ) {
        self.interactor = interactor
        self.router = router
        self.roomId = roomId
        self.task = task
        self.onTaskSaved = onTaskSaved
        self.taskName = task?.name ?? ""
        self.selectedFrequency = (task?.frequency ?? .timesPerWeek(1)).canonicalized
    }

    // MARK: - Actions

    func onCancelButtonPressed() {
        router.dismissScreen()
    }

    func onSaveButtonPressed() {
        guard isTaskNameValid else { return }

        let updatedTask = RoomTask(
            id: task?.id ?? UUID(),
            name: taskName.trimmingCharacters(in: .whitespaces),
            roomId: roomId,
            frequency: selectedFrequency,
            estimatedDuration: task?.estimatedDuration ?? .fifteenMinutes,
            createdAt: task?.createdAt ?? Date()
        )

        do {
            if task == nil {
                try interactor.saveRoomTask(updatedTask)
            } else {
                try interactor.updateRoomTask(updatedTask)
            }
            router.dismissScreen()
            DispatchQueue.main.async {
                self.onTaskSaved(updatedTask)
            }
        } catch {
            // TODO: Surface a save error in the sheet when app-level error presentation is added.
        }
    }
}
