import Foundation

// MARK: - RoomType + SuggestedTasks

extension RoomType {
	// MARK: - Suggested Tasks

	/// Returns a list of pre-populated `RoomTask` values for this room type.
	/// Task `id`s are stable hardcoded UUIDs so identity is preserved across
	/// multiple calls (required for selection state matching).
	/// The `roomId` is a placeholder — callers must replace it before persisting.
	var suggestedTasks: [RoomTask] {
		let placeholder = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
		return switch self {
		case .kitchen:
			[
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000001")!,
					name: "Wipe countertops",
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000002")!,
					name: "Clean hob",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000003")!,
					name: "Empty bin",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000004")!,
					name: "Clean sink",
					roomId: placeholder,
					frequency: .timesPerWeek(3),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000005")!,
					name: "Wipe appliances",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000006")!,
					name: "Clean oven",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000007")!,
					name: "Defrost freezer",
					roomId: placeholder,
					frequency: .quarterly,
					estimatedDuration: .sixtyMinutes
				),
			]
		case .livingRoom:
			[
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000001")!,
					name: "Vacuum",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000002")!,
					name: "Dust surfaces",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000003")!,
					name: "Wipe TV screen",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000004")!,
					name: "Tidy cushions",
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000005")!,
					name: "Clean windows",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
			]
		case .bedroom:
			[
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000001")!,
					name: "Make bed",
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000002")!,
					name: "Vacuum",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000003")!,
					name: "Dust surfaces",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000004")!,
					name: "Change bed linen",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000005")!,
					name: "Tidy wardrobe",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
			]
		case .bathroom:
			[
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000001")!,
					name: "Clean toilet",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000002")!,
					name: "Wipe sink",
					roomId: placeholder,
					frequency: .timesPerWeek(3),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000003")!,
					name: "Clean shower / bath",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000004")!,
					name: "Mop floor",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000005")!,
					name: "Wipe mirror",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000006")!,
					name: "Descale taps",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
			]
		case .hallway:
			[
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000001")!,
					name: "Vacuum / sweep",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000002")!,
					name: "Wipe door handles",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000003")!,
					name: "Organise shoes",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000004")!,
					name: "Dust shelves",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000005")!,
					name: "Clean front door",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
			]
		case .office:
			[
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000001")!,
					name: "Wipe desk",
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000002")!,
					name: "Dust monitor & keyboard",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000003")!,
					name: "Vacuum",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000004")!,
					name: "Tidy cables",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000005")!,
					name: "Clean windows",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
			]
		case .garage:
			[
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000001")!,
					name: "Sweep floor",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000002")!,
					name: "Organise tools",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000003")!,
					name: "Remove rubbish",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000004")!,
					name: "Wipe shelves",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
			]
		case .laundry:
			[
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000001")!,
					name: "Wipe washing machine drum",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000002")!,
					name: "Clean lint filter",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000003")!,
					name: "Descale washing machine",
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000004")!,
					name: "Sweep floor",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
			]
		case .toilet:
			[
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000001")!,
					name: "Clean toilet bowl",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000002")!,
					name: "Wipe seat & lid",
					roomId: placeholder,
					frequency: .timesPerWeek(3),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000003")!,
					name: "Wipe sink",
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000004")!,
					name: "Mop floor",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000005")!,
					name: "Restock supplies",
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
			]
		case .custom:
			[]
		}
	}
}
