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

    var taskName = ""
    var selectedFrequency: Frequency = .timesPerWeek(1)

    var isTaskNameValid: Bool {
        !taskName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Init

    init(
        interactor: any AddCustomTaskSheetInteractor,
        router: any AddCustomTaskSheetRouter,
        roomId: UUID
    ) {
        self.interactor = interactor
        self.router = router
        self.roomId = roomId
    }

    // MARK: - Actions

    func onCancelButtonPressed() {
        router.dismissScreen()
    }

    func onAddButtonPressed() {
        guard isTaskNameValid else { return }

        let task = RoomTask(
            name: taskName.trimmingCharacters(in: .whitespaces),
            roomId: roomId,
            frequency: selectedFrequency,
            estimatedDuration: .fifteenMinutes
        )

        do {
            try interactor.saveRoomTask(task)
            router.dismissScreen()
        } catch {
            // TODO: Surface a save error in the sheet when app-level error presentation is added.
        }
    }
}
