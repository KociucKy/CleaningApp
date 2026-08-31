import Foundation

// MARK: - CustomRoomSheetRouter

@MainActor
protocol CustomRoomSheetRouter {
    func dismissScreen()
    func showIconPicker(roomName: String)
}

extension CoreRouter: CustomRoomSheetRouter {}
