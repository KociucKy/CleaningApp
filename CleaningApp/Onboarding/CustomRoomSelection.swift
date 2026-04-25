import Foundation

// MARK: - CustomRoomSelection

/// Represents a custom room created during onboarding.
@MainActor
struct CustomRoomSelection: Identifiable, Equatable {
	// MARK: - Properties

	let id: UUID
	let name: String
	let icon: String
	var selectedTasks: [RoomTask]

	// MARK: - Init

	init(id: UUID = UUID(), name: String, icon: String, selectedTasks: [RoomTask] = []) {
		self.id = id
		self.name = name
		self.icon = icon
		self.selectedTasks = selectedTasks
	}
}
