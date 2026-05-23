import Foundation

struct Room: Identifiable, Equatable {
	// MARK: - Properties

	let id: UUID
	var name: String
	var kind: RoomType
	var isCustom: Bool
	var customIcon: String?
	let createdAt: Date

	// MARK: - Init

	init(
		id: UUID = UUID(),
		name: String,
		kind: RoomType,
		isCustom: Bool = false,
		customIcon: String? = nil,
		createdAt: Date = Date()
	) {
		self.id = id
		self.name = name
		self.kind = kind
		self.isCustom = isCustom
		self.customIcon = customIcon
		self.createdAt = createdAt
	}
}
