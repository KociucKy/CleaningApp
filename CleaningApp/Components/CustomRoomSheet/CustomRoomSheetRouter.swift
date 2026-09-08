import Foundation

// MARK: - CustomRoomSheetRouter

@MainActor
protocol CustomRoomSheetRouter {
    func dismissScreen()
    func dismissToRoot()
    func showIconPicker(roomName: String, room: Room?, onRoomSaved: ((Room) -> Void)?)
}

extension CoreRouter: CustomRoomSheetRouter {}
