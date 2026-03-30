import Foundation

struct Room: Identifiable, Equatable {
	// MARK: - Properties

	let id: UUID
	var name: String
	var icon: RoomIcon
	let createdAt: Date

	// MARK: - Init

	init(
		id: UUID = UUID(),
		name: String,
		icon: RoomIcon,
		createdAt: Date = Date()
	) {
		self.id = id
		self.name = name
		self.icon = icon
		self.createdAt = createdAt
	}
}
