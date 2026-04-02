import Foundation

// MARK: - RoomType + SuggestedTasks

extension RoomType {
	// MARK: - Suggested Tasks

	/// Returns a list of pre-populated `RoomTask` values for this room type.
	/// The `roomId` is a placeholder (`UUID()`) — callers must replace it with
	/// the real room ID before persisting.
	var suggestedTasks: [RoomTask] {
		switch self {
		case .kitchen:
			[
				RoomTask(name: "Wipe countertops", roomId: UUID(), frequency: .daily, estimatedDuration: .fiveMinutes),
				RoomTask(name: "Clean hob", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .tenMinutes),
				RoomTask(name: "Empty bin", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Clean sink", roomId: UUID(), frequency: .timesPerWeek(3), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Wipe appliances", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
				RoomTask(name: "Clean oven", roomId: UUID(), frequency: .monthly, estimatedDuration: .thirtyMinutes),
				RoomTask(name: "Defrost freezer", roomId: UUID(), frequency: .quarterly, estimatedDuration: .sixtyMinutes),
			]
		case .livingRoom:
			[
				RoomTask(name: "Vacuum", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .fifteenMinutes),
				RoomTask(name: "Dust surfaces", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
				RoomTask(name: "Wipe TV screen", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Tidy cushions", roomId: UUID(), frequency: .daily, estimatedDuration: .fiveMinutes),
				RoomTask(name: "Clean windows", roomId: UUID(), frequency: .monthly, estimatedDuration: .thirtyMinutes),
			]
		case .bedroom:
			[
				RoomTask(name: "Make bed", roomId: UUID(), frequency: .daily, estimatedDuration: .fiveMinutes),
				RoomTask(name: "Vacuum", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fifteenMinutes),
				RoomTask(name: "Dust surfaces", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
				RoomTask(name: "Change bed linen", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fifteenMinutes),
				RoomTask(name: "Tidy wardrobe", roomId: UUID(), frequency: .monthly, estimatedDuration: .thirtyMinutes),
			]
		case .bathroom:
			[
				RoomTask(name: "Clean toilet", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .tenMinutes),
				RoomTask(name: "Wipe sink", roomId: UUID(), frequency: .timesPerWeek(3), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Clean shower / bath", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fifteenMinutes),
				RoomTask(name: "Mop floor", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
				RoomTask(name: "Wipe mirror", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Descale taps", roomId: UUID(), frequency: .monthly, estimatedDuration: .fifteenMinutes),
			]
		case .hallway:
			[
				RoomTask(name: "Vacuum / sweep", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .tenMinutes),
				RoomTask(name: "Wipe door handles", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Organise shoes", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Dust shelves", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Clean front door", roomId: UUID(), frequency: .monthly, estimatedDuration: .fifteenMinutes),
			]
		case .office:
			[
				RoomTask(name: "Wipe desk", roomId: UUID(), frequency: .daily, estimatedDuration: .fiveMinutes),
				RoomTask(name: "Dust monitor & keyboard", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
				RoomTask(name: "Vacuum", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fifteenMinutes),
				RoomTask(name: "Tidy cables", roomId: UUID(), frequency: .monthly, estimatedDuration: .fifteenMinutes),
				RoomTask(name: "Clean windows", roomId: UUID(), frequency: .monthly, estimatedDuration: .thirtyMinutes),
			]
		case .garage:
			[
				RoomTask(name: "Sweep floor", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fifteenMinutes),
				RoomTask(name: "Organise tools", roomId: UUID(), frequency: .monthly, estimatedDuration: .thirtyMinutes),
				RoomTask(name: "Remove rubbish", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
				RoomTask(name: "Wipe shelves", roomId: UUID(), frequency: .monthly, estimatedDuration: .fifteenMinutes),
			]
		case .laundry:
			[
				RoomTask(name: "Wipe washing machine drum", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Clean lint filter", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Descale washing machine", roomId: UUID(), frequency: .monthly, estimatedDuration: .tenMinutes),
				RoomTask(name: "Sweep floor", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
			]
		case .toilet:
			[
				RoomTask(name: "Clean toilet bowl", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .tenMinutes),
				RoomTask(name: "Wipe seat & lid", roomId: UUID(), frequency: .timesPerWeek(3), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Wipe sink", roomId: UUID(), frequency: .timesPerWeek(2), estimatedDuration: .fiveMinutes),
				RoomTask(name: "Mop floor", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .tenMinutes),
				RoomTask(name: "Restock supplies", roomId: UUID(), frequency: .timesPerWeek(1), estimatedDuration: .fiveMinutes),
			]
		case .custom:
			[]
		}
	}
}
