#if MOCK
	import Foundation

	extension RoomEntity {
		static let mockId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

		// MARK: - Mocks

		static var mock: RoomEntity {
			mocks.first!
		}

		static var mocks: [RoomEntity] {
			[
				RoomEntity(
					id: mockId,
					name: "Living Room",
					icon: "livingRoom",
					createdAt: .mock
				),
				RoomEntity(
					id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
					name: "Kitchen",
					icon: "kitchen",
					createdAt: .mock
				),
				RoomEntity(
					id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
					name: "Bedroom",
					icon: "bedroom",
					createdAt: .mock
				),
			]
		}
	}
#endif
