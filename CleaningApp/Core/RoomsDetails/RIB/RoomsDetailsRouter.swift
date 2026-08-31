import Foundation
import NavigationKit

@MainActor
protocol RoomsDetailsRouter {
	func presentRoomsDetailsTaskCompletionSheet(props: RoomsDetailsTaskCompletionProps)
	func presentAddCustomTaskSheet(roomId: UUID, onTaskAdded: @escaping () -> Void)
}

extension CoreRouter: RoomsDetailsRouter {}
