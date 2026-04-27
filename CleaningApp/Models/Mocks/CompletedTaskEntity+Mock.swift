import Foundation

extension CompletedTaskEntity {
	static let mockId = UUID(uuidString: "00000000-0000-0000-0002-000000000001")!

	// MARK: - Mocks

	static var mock: CompletedTaskEntity {
		mocks.first!
	}

	static var mocks: [CompletedTaskEntity] {
		[
			CompletedTaskEntity(
				id: mockId,
				taskId: RoomTaskEntity.mockId,
				completedAt: .mock,
				measuredDuration: 25
			),
			CompletedTaskEntity(
				id: UUID(uuidString: "00000000-0000-0000-0002-000000000002")!,
				taskId: RoomTaskEntity.mockId,
				completedAt: .mock.addingTimeInterval(86400),
				measuredDuration: nil
			)
		]
	}
}
