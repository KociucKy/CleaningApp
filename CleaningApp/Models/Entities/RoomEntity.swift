import Foundation
import SwiftData

@Model
final class RoomEntity {
	// MARK: - Properties

	var id: UUID
	var name: String
	var icon: String
	var isCustom: Bool
	var customIcon: String?
	var createdAt: Date

	@Relationship(deleteRule: .cascade, inverse: \RoomTaskEntity.room)
	var tasks: [RoomTaskEntity] = []

	// MARK: - Init

	init(
		id: UUID = UUID(),
		name: String,
		icon: String,
		isCustom: Bool = false,
		customIcon: String? = nil,
		createdAt: Date = Date()
	) {
		self.id = id
		self.name = name
		self.icon = icon
		self.isCustom = isCustom
		self.customIcon = customIcon
		self.createdAt = createdAt
	}
}
