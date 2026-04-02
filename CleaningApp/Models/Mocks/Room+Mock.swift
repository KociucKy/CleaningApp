import Foundation

extension Room {
	static let mockId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

	// MARK: - Mocks

	static var mock: Room {
		mocks.first!
	}

	static var mocks: [Room] {
		[
			Room(
				id: mockId,
				name: "Living Room",
				kind: .livingRoom,
				createdAt: .mock
			),
			Room(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
				name: "Kitchen",
				kind: .kitchen,
				createdAt: .mock
			),
			Room(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
				name: "Bedroom",
				kind: .bedroom,
				createdAt: .mock
			),
		]
	}
}
