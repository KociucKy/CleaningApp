import Foundation
import NavigationKit

// MARK: - RoomsRouter

@MainActor
protocol RoomsRouter {
	func dismissScreen()
	func presentRoomsDetailsView()
	func presentAddCustomRoomSheet(onDismiss: (() -> Void)?)
}

extension CoreRouter: RoomsRouter {}
