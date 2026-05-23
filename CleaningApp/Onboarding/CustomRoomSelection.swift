import Foundation

// MARK: - CustomRoomSelection

/// Represents a custom room created during onboarding.
@MainActor
struct CustomRoomSelection: Identifiable, Equatable, Hashable {
	// MARK: - Properties

	let id: UUID
	let name: String
	let icon: String
	var isSelected: Bool
	var allTasks: [RoomTask]
	var selectedTaskIds: Set<UUID>

	// MARK: - Init

	init(id: UUID = UUID(), name: String, icon: String, isSelected: Bool = true, allTasks: [RoomTask] = [], selectedTaskIds: Set<UUID> = []) {
		self.id = id
		self.name = name
		self.icon = icon
		self.isSelected = isSelected
		self.allTasks = allTasks
		self.selectedTaskIds = selectedTaskIds
	}

	// MARK: - Computed Properties

	/// Returns only the selected tasks from allTasks.
	var selectedTasks: [RoomTask] {
		allTasks.filter { selectedTaskIds.contains($0.id) }
	}

	// MARK: - Equatable

	nonisolated static func == (lhs: CustomRoomSelection, rhs: CustomRoomSelection) -> Bool {
		lhs.id == rhs.id
	}

	// MARK: - Hashable

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
