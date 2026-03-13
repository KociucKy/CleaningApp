import Foundation
import NavigationKit

// MARK: - DevSettingsRouter

@MainActor
protocol DevSettingsRouter {
	func presentReviewKitDebugView()
	func presentUserDefaultsDebugView()
	func presentLocalNotificationDebugView()
	func presentDeviceDebugView()
	func dismissScreen()
}

extension CoreRouter: DevSettingsRouter {}
