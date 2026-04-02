import Foundation

struct Room: Identifiable, Equatable {
	// MARK: - Properties

	let id: UUID
	var name: String
	var kind: RoomType
	let createdAt: Date

	// MARK: - Init

	init(
		id: UUID = UUID(),
		name: String,
		kind: RoomType,
		createdAt: Date = Date()
	) {
		self.id = id
		self.name = name
		self.kind = kind
		self.createdAt = createdAt
	}
}
