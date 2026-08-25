import Foundation

// MARK: - CustomRoomSheetInteractor

@MainActor
protocol CustomRoomSheetInteractor {
    func saveCustomRoom(name: String, icon: String) throws
}
