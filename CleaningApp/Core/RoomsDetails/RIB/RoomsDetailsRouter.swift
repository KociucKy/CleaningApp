import Foundation
import NavigationKit

@MainActor
protocol RoomsDetailsRouter {
	func presentRoomsDetailsTaskCompletionSheet(props: RoomsDetailsTaskCompletionProps)
	func presentAddCustomTaskSheet(roomId: UUID)
}

extension CoreRouter: RoomsDetailsRouter {}
