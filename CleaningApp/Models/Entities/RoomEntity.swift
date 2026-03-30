import Foundation
import SwiftData

@Model
final class RoomEntity {
	// MARK: - Properties

	var id: UUID
	var name: String
	var icon: String
	var createdAt: Date

	@Relationship(deleteRule: .cascade, inverse: \RoomTaskEntity.room)
	var tasks: [RoomTaskEntity] = []

	// MARK: - Init

	init(
		id: UUID = UUID(),
		name: String,
		icon: String,
		createdAt: Date = Date()
	) {
		self.id = id
		self.name = name
		self.icon = icon
		self.createdAt = createdAt
	}
}
