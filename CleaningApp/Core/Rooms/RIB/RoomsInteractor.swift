import Foundation

// MARK: - RoomsInteractor

@MainActor
protocol RoomsInteractor {
	func fetchRooms() throws -> [Room]
}

extension CoreInteractor: RoomsInteractor {
	func fetchRooms() throws -> [Room] {
		try fetchAllRooms()
	}
}
