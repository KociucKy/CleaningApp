import Foundation

@MainActor
protocol ActivityLogRouter {
	func dismissScreen()
}

extension CoreRouter: ActivityLogRouter {}
