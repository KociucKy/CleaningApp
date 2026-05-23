import Foundation

extension SkippedTask {
	static var mock: SkippedTask {
		.mocks.first!
	}

	static var mocks: [SkippedTask] {
		[
			SkippedTask(
				id: UUID(uuidString: "00000000-0000-0000-0003-000000000001")!,
				taskId: RoomTask.mockId,
				originalDate: .mock,
				skippedAt: .mock.addingTimeInterval(3600)
			),
			SkippedTask(
				id: UUID(uuidString: "00000000-0000-0000-0003-000000000002")!,
				taskId: RoomTask.mockId,
				originalDate: .mock.addingTimeInterval(86400),
				skippedAt: .mock.addingTimeInterval(90000)
			)
		]
	}
}
