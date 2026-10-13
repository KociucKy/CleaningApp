import SwiftUI

// MARK: - ActivityLogEditPresenter

@Observable
@MainActor
final class ActivityLogEditPresenter {
    // MARK: - Properties

    private let interactor: any ActivityLogInteractor
    private let router: any ActivityLogRouter
    private let completedTask: CompletedTask

    var completedAt: Date

    // MARK: - Init

    init(
        interactor: any ActivityLogInteractor,
        router: any ActivityLogRouter,
        completedTask: CompletedTask
    ) {
        self.interactor = interactor
        self.router = router
        self.completedTask = completedTask
        completedAt = completedTask.completedAt
    }

    // MARK: - Actions

    func onCancelButtonTapped() {
        router.dismissScreen()
    }

    func onSaveButtonTapped() {
        let updatedTask = CompletedTask(
            id: completedTask.id,
            taskId: completedTask.taskId,
            roomId: completedTask.roomId,
            roomName: completedTask.roomName,
            taskName: completedTask.taskName,
            completedAt: completedAt,
            measuredDuration: completedTask.measuredDuration
        )

        do {
            try interactor.updateCompletedTask(updatedTask)
            router.dismissScreen()
        } catch {
            return
        }
    }
}
