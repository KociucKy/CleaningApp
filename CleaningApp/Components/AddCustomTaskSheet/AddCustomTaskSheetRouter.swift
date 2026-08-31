import Foundation

// MARK: - AddCustomTaskSheetRouter

@MainActor
protocol AddCustomTaskSheetRouter {
	func dismissScreen()
}

extension CoreRouter: AddCustomTaskSheetRouter {}
