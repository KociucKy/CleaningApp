import Foundation

@MainActor
protocol CustomRoomSheetInteractor {
	func saveCustomRoom(name: String, icon: String) throws
	func updateRoom(_ room: Room) throws
}

extension CoreInteractor: CustomRoomSheetInteractor {}
