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
					name: String(localized: "task.wipe_countertops"),
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.clean_hob"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.empty_bin"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.clean_sink"),
					roomId: placeholder,
					frequency: .timesPerWeek(3),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.wipe_appliances"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000006")!,
					name: String(localized: "task.clean_oven"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A1000000-0000-0000-0000-000000000007")!,
					name: String(localized: "task.defrost_freezer"),
					roomId: placeholder,
					frequency: .quarterly,
					estimatedDuration: .sixtyMinutes
				),
			]
		case .livingRoom:
			[
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.vacuum"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.dust_surfaces"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.wipe_tv_screen"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.tidy_cushions"),
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A2000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.clean_windows"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
			]
		case .bedroom:
			[
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.make_bed"),
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.vacuum"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.dust_surfaces"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.change_bed_linen"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A3000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.tidy_wardrobe"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
			]
		case .bathroom:
			[
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.clean_toilet"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.wipe_sink"),
					roomId: placeholder,
					frequency: .timesPerWeek(3),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.clean_shower_bath"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.mop_floor"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.wipe_mirror"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A4000000-0000-0000-0000-000000000006")!,
					name: String(localized: "task.descale_taps"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
			]
		case .hallway:
			[
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.vacuum_sweep"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.wipe_door_handles"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.organise_shoes"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.dust_shelves"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A5000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.clean_front_door"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
			]
		case .office:
			[
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.wipe_desk"),
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.dust_monitor_keyboard"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.vacuum"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.tidy_cables"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A6000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.clean_windows"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
			]
		case .garage:
			[
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.sweep_floor"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.organise_tools"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.remove_rubbish"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A7000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.wipe_shelves"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
			]
		case .laundry:
			[
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.wipe_washing_machine_drum"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.clean_lint_filter"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.descale_washing_machine"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A8000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.sweep_floor"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
			]
		case .toilet:
			[
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.clean_toilet_bowl"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.wipe_seat_lid"),
					roomId: placeholder,
					frequency: .timesPerWeek(3),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.wipe_sink"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.mop_floor"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "A9000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.restock_supplies"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .fiveMinutes
				),
			]
		case .diningRoom:
			[
				RoomTask(
					id: UUID(uuidString: "AA000000-0000-0000-0000-000000000001")!,
					name: String(localized: "task.wipe_table"),
					roomId: placeholder,
					frequency: .daily,
					estimatedDuration: .fiveMinutes
				),
				RoomTask(
					id: UUID(uuidString: "AA000000-0000-0000-0000-000000000002")!,
					name: String(localized: "task.vacuum_sweep"),
					roomId: placeholder,
					frequency: .timesPerWeek(2),
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "AA000000-0000-0000-0000-000000000003")!,
					name: String(localized: "task.dust_surfaces"),
					roomId: placeholder,
					frequency: .timesPerWeek(1),
					estimatedDuration: .tenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "AA000000-0000-0000-0000-000000000004")!,
					name: String(localized: "task.clean_light_fixtures"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .fifteenMinutes
				),
				RoomTask(
					id: UUID(uuidString: "AA000000-0000-0000-0000-000000000005")!,
					name: String(localized: "task.polish_furniture"),
					roomId: placeholder,
					frequency: .monthly,
					estimatedDuration: .thirtyMinutes
				),
			]
		case .customRoom:
			[]
		}
	}
}
