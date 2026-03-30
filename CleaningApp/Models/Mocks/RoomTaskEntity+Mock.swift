import Foundation

extension RoomTaskEntity {
	static let mockId = UUID(uuidString: "00000000-0000-0000-0001-000000000001")!

	// MARK: - Mocks

	static var mock: RoomTaskEntity {
		mocks.first!
	}

	static var mocks: [RoomTaskEntity] {
		[
			RoomTaskEntity(
				id: mockId,
				name: "Vacuum floor",
				room: .mock,
				frequencyEncoded: "timesPerWeek(2)",
				estimatedDuration: 30,
				createdAt: .mock
			),
			RoomTaskEntity(
				id: UUID(uuidString: "00000000-0000-0000-0001-000000000002")!,
				name: "Wipe surfaces",
				room: .mock,
				frequencyEncoded: "timesPerWeek(1)",
				estimatedDuration: 15,
				createdAt: .mock
			),
			RoomTaskEntity(
				id: UUID(uuidString: "00000000-0000-0000-0001-000000000003")!,
				name: "Clean windows",
				room: .mock,
				frequencyEncoded: "monthly",
				estimatedDuration: 60,
				createdAt: .mock
			),
		]
	}
}
