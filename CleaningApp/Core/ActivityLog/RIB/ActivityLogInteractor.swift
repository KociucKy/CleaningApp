import Foundation

@MainActor
protocol ActivityLogInteractor {
	func fetchCompletedTasks(
		forRoomId roomId: UUID,
		limit: Int,
		offset: Int
	) throws -> [CompletedTask]
	func updateCompletedTask(_ item: CompletedTask) throws
	func deleteCompletedTask(_ item: CompletedTask) throws
}

extension CoreInteractor: ActivityLogInteractor {}
