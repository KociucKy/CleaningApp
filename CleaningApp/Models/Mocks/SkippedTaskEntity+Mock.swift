import Foundation

extension SkippedTaskEntity {
	static let mockId = UUID(uuidString: "00000000-0000-0000-0003-000000000001")!

	// MARK: - Mocks

	static var mock: SkippedTaskEntity {
		mocks.first!
	}

	static var mocks: [SkippedTaskEntity] {
		[
			SkippedTaskEntity(
				id: mockId,
				taskId: RoomTaskEntity.mockId,
				originalDate: .mock,
				skippedAt: .mock.addingTimeInterval(3600)
			),
			SkippedTaskEntity(
				id: UUID(uuidString: "00000000-0000-0000-0003-000000000002")!,
				taskId: RoomTaskEntity.mockId,
				originalDate: .mock.addingTimeInterval(86400),
				skippedAt: .mock.addingTimeInterval(90000)
			)
		]
	}
}
