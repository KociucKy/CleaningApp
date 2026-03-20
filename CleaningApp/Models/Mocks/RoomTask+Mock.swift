#if MOCK
	import Foundation

	extension RoomTask {
		static let mockId = UUID(uuidString: "00000000-0000-0000-0001-000000000001")!

		static var mock: RoomTask {
			.mocks.first!
		}

		static var mocks: [RoomTask] {
			[
				RoomTask(
					id: mockId,
					name: "Vacuum floor",
					roomId: Room.mockId,
					frequency: .timesPerWeek(2),
					estimatedDuration: .thirtyMinutes,
					createdAt: .mock
				),
				RoomTask(
					id: UUID(uuidString: "00000000-0000-0000-0001-000000000002")!,
					name: "Wipe surfaces",
					roomId: Room.mockId,
					frequency: .weekly,
					estimatedDuration: .fifteenMinutes,
					createdAt: .mock
				),
				RoomTask(
					id: UUID(uuidString: "00000000-0000-0000-0001-000000000003")!,
					name: "Clean windows",
					roomId: Room.mockId,
					frequency: .monthly,
					estimatedDuration: .sixtyMinutes,
					createdAt: .mock
				),
			]
		}
	}

	// MARK: - Frequency + Mock

	extension Frequency {
		static var weekly: Frequency {
			.timesPerWeek(1)
		}
	}
#endif
