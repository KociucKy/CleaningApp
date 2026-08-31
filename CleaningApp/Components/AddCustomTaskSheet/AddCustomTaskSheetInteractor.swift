import Foundation

// MARK: - AddCustomTaskSheetInteractor

@MainActor
protocol AddCustomTaskSheetInteractor {
    func saveRoomTask(_ task: RoomTask) throws
}

extension CoreInteractor: AddCustomTaskSheetInteractor {}
