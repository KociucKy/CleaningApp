import Foundation

extension CompletedTask {
	static var mock: CompletedTask {
		mocks.first!
	}

	static var mocks: [CompletedTask] {
		[
			CompletedTask(
				id: UUID(uuidString: "00000000-0000-0000-0002-000000000001")!,
				taskId: RoomTask.mockId,
				completedAt: .mock,
				measuredDuration: 25
			),
			CompletedTask(
				id: UUID(uuidString: "00000000-0000-0000-0002-000000000002")!,
				taskId: RoomTask.mockId,
				completedAt: .mock.addingTimeInterval(86400),
				measuredDuration: nil
			),
		]
	}
}
