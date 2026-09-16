import Foundation

// MARK: - CustomRoomSheetRouter

@MainActor
protocol CustomRoomSheetRouter {
    func dismissScreen()
    func dismissToRoot()
}

extension CoreRouter: CustomRoomSheetRouter {}
