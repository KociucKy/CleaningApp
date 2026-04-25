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
	case diningRoom = "Dining Room"
	case customRoom = "Custom Room"

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
		case .diningRoom: String(localized: "room_type.dining_room")
		case .customRoom: String(localized: "room_type.custom_room")
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
		case .diningRoom: "fork.knife.circle"
		case .customRoom: "square.grid.2x2"
		}
	}
}
