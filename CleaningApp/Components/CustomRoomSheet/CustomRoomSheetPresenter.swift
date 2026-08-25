import SwiftUI

// MARK: - CustomRoomSheetPresenter

@Observable
@MainActor
final class CustomRoomSheetPresenter {
    // MARK: - Properties

    private let interactor: any CustomRoomSheetInteractor
    private let router: any CustomRoomSheetRouter

    var roomName: String = ""

    var isNameValid: Bool {
        !roomName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Init

    init(
        interactor: any CustomRoomSheetInteractor,
        router: any CustomRoomSheetRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - Actions

    func onCancelButtonPressed() {
        router.dismissScreen()
    }

    func onNextButtonPressed() {
        guard isNameValid else { return }
        let trimmedName = roomName.trimmingCharacters(in: .whitespaces)
        router.showIconPicker(roomName: trimmedName)
    }
}
