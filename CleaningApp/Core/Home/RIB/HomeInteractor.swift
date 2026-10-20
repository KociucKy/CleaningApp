import Foundation
import NavigationKit

// MARK: - HomeInteractor

@MainActor
protocol HomeInteractor {
	var onboardingCompletionToken: Int { get }
	func fetchAllRooms() throws -> [Room]
	func fetchAllRoomTasks() throws -> [RoomTask]
	func fetchAllScheduledTasks() throws -> [ScheduledTask]
}

extension CoreInteractor: HomeInteractor {}
