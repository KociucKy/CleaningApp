import Foundation

// MARK: - CustomRoomSelection

/// Represents a custom room created during onboarding.
@MainActor
struct CustomRoomSelection: Identifiable, Equatable {
	// MARK: - Properties

	let id: UUID
	let name: String
	let icon: String
	var isSelected: Bool
	var selectedTasks: [RoomTask]

	// MARK: - Init

	init(id: UUID = UUID(), name: String, icon: String, isSelected: Bool = true, selectedTasks: [RoomTask] = []) {
		self.id = id
		self.name = name
		self.icon = icon
		self.isSelected = isSelected
		self.selectedTasks = selectedTasks
	}
}
