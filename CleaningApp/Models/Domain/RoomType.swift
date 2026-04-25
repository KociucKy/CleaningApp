import Foundation

enum RoomType: String, CaseIterable, Codable, Identifiable {
	var id: Self {
		self
	}

	case kitchen = "Kitchen"
	case livingRoom = "Living Room"
	case bedroom = "Bedroom"
	case bathroom = "Bathroom"
	case hallway = "Hallway"
	case office = "Office"
	case garage = "Garage"
	case laundry = "Laundry"
	case toilet = "Toilet"
	case custom = "Custom"

	var localizedName: String {
		switch self {
		case .kitchen: String(localized: "room_type.kitchen")
		case .livingRoom: String(localized: "room_type.living_room")
		case .bedroom: String(localized: "room_type.bedroom")
		case .bathroom: String(localized: "room_type.bathroom")
		case .hallway: String(localized: "room_type.hallway")
		case .office: String(localized: "room_type.office")
		case .garage: String(localized: "room_type.garage")
		case .laundry: String(localized: "room_type.laundry")
		case .toilet: String(localized: "room_type.toilet")
		case .custom: String(localized: "room_type.custom")
		}
	}

	var symbolName: String {
		switch self {
		case .kitchen: "fork.knife"
		case .livingRoom: "sofa"
		case .bedroom: "bed.double"
		case .bathroom: "shower"
		case .hallway: "door.left.hand.open"
		case .office: "desktopcomputer"
		case .garage: "car"
		case .laundry: "washer"
		case .toilet: "toilet"
		case .custom: "square.grid.2x2"
		}
	}
}
