import Foundation
import NavigationKit

// MARK: - DevSettingsRouter

@MainActor
protocol DevSettingsRouter {
	func presentReviewKitDebugView()
	func dismissScreen()
}

extension CoreRouter: DevSettingsRouter {}
