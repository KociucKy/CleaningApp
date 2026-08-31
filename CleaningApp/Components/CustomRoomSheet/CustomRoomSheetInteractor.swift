import Foundation

@MainActor
protocol CustomRoomSheetInteractor {
	func saveCustomRoom(name: String, icon: String) throws
}

extension CoreInteractor: CustomRoomSheetInteractor {}
