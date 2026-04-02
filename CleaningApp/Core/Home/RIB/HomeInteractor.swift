import Foundation
import NavigationKit

// MARK: - HomeInteractor

@MainActor
protocol HomeInteractor {
	func fetchAllRooms() throws -> [Room]
	func fetchAllRoomTasks() throws -> [RoomTask]
}

extension CoreInteractor: HomeInteractor {}
