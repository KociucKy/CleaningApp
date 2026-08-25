import Foundation

// MARK: - IconPickerPresenter

@Observable
@MainActor
final class IconPickerPresenter {
    // MARK: - Properties

    private let interactor: any CustomRoomSheetInteractor
    private let router: any CustomRoomSheetRouter
    private let roomName: String

    let icons: [String] = [
        "house.fill",
        "bed.double.fill",
        "dumbbell",
        "book.fill",
        "paintpalette.fill",
        "leaf.fill",
        "wrench.and.screwdriver.fill",
        "music.note",
        "gamecontroller.fill",
        "laptopcomputer",
        "tv.fill",
        "car.fill",
        "cart.fill",
        "tent.fill",
        "pawprint.fill",
        "figure.walk",
        "tshirt.fill",
        "cup.and.saucer.fill",
        "square.grid.2x2",
    ]

    // MARK: - Init

    init(
        interactor: any CustomRoomSheetInteractor,
        router: any CustomRoomSheetRouter,
        roomName: String
    ) {
        self.interactor = interactor
        self.router = router
        self.roomName = roomName
    }

    // MARK: - Actions

    func onIconSelected(_ icon: String) {
        try? interactor.saveCustomRoom(name: roomName, icon: icon)
        router.dismissScreen()
    }
}
