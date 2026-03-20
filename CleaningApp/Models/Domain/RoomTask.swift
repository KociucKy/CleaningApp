import Foundation

struct RoomTask: Identifiable, Equatable {
	// MARK: - Properties

	let id: UUID
	var name: String
	var roomId: UUID
	var frequency: Frequency
	var estimatedDuration: TaskDuration
	let createdAt: Date

	// MARK: - Init

	init(
		id: UUID = UUID(),
		name: String,
		roomId: UUID,
		frequency: Frequency,
		estimatedDuration: TaskDuration,
		createdAt: Date = Date()
	) {
		self.id = id
		self.name = name
		self.roomId = roomId
		self.frequency = frequency
		self.estimatedDuration = estimatedDuration
		self.createdAt = createdAt
	}
}
