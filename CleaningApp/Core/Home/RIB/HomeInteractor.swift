import Foundation
import NavigationKit

// MARK: - HomeInteractor

@MainActor
protocol HomeInteractor {
	func fetchAllRooms() throws -> [Room]
}

extension CoreInteractor: HomeInteractor {}
