import Foundation
import UtilitiesKit

extension CompletedTaskEntity {
	static let mockId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

	// MARK: - Mocks

	static var mock: CompletedTaskEntity {
		mocks.first!
	}

	static var mocks: [CompletedTaskEntity] {
		[
			.init(
				id: mockId,
				taskId: UUID(uuidString: "00000000-0000-0000-0001-000000000001")!,
				roomId: UUID(uuidString: "00000000-0000-0001-0000-000000000001"),
				roomName: "Living Room",
				taskName: "Vacuum floor",
				completedAt: Date.randomPast(daysBack: 3),
				measuredDuration: 15
			)
		]
	}
}
