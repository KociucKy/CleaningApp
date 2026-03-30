import Foundation
import SwiftData

@Model
final class CompletedTaskEntity {
	// MARK: - Properties

	var id: UUID
	var taskId: UUID
	var completedAt: Date
	var measuredDuration: Int?

	// MARK: - Init

	init(
		id: UUID = UUID(),
		taskId: UUID,
		completedAt: Date = Date(),
		measuredDuration: Int? = nil
	) {
		self.id = id
		self.taskId = taskId
		self.completedAt = completedAt
		self.measuredDuration = measuredDuration
	}
}
