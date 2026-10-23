import Foundation
import SwiftData

@Model
final class RoomTaskEntity {
	// MARK: - Properties

	var id: UUID
	var name: String
	var room: RoomEntity?
	var frequencyEncoded: String
	var estimatedDuration: Int
	var learnedDuration: Int?
	var createdAt: Date

	// MARK: - Init

	init(
		id: UUID = UUID(),
		name: String,
		room: RoomEntity? = nil,
		frequencyEncoded: String,
		estimatedDuration: Int,
		learnedDuration: Int? = nil,
		createdAt: Date = Date()
	) {
		self.id = id
		self.name = name
		self.room = room
		self.frequencyEncoded = frequencyEncoded
		self.estimatedDuration = estimatedDuration
		self.learnedDuration = learnedDuration
		self.createdAt = createdAt
	}
}
