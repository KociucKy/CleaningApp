import Foundation
import NavigationKit

@MainActor
protocol RoomsDetailsRouter {
	func presentRoomsDetailsTaskCompletionSheet(taskName: String)
}

extension CoreRouter: RoomsDetailsRouter {}
