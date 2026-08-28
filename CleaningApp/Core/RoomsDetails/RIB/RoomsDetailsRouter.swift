import Foundation
import NavigationKit

@MainActor
protocol RoomsDetailsRouter {
	func presentRoomsDetailsTaskCompletionSheet()
}

extension CoreRouter: RoomsDetailsRouter {}
