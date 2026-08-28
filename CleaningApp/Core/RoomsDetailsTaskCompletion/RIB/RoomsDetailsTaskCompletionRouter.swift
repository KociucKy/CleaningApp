import Foundation

@MainActor
protocol RoomsDetailsTaskCompletionRouter {
	func dismissScreen()
}

extension CoreRouter: RoomsDetailsTaskCompletionRouter {}
