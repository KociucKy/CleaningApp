import Foundation

// MARK: - RoomsInteractor

@MainActor
protocol RoomsInteractor {
	func fetchAllRooms() throws -> [Room]
	func deleteRoom(_ item: Room) throws
}

extension CoreInteractor: RoomsInteractor {}
