import Foundation

enum RoomIcon: String, CaseIterable, Codable {
	case kitchen
	case livingRoom
	case bedroom
	case bathroom
	case hallway
	case office
	case garage
	case laundry
	case toilet
	case custom

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
