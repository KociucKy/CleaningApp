import Foundation

enum RoomIcon: String, CaseIterable, Codable, Identifiable {
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
