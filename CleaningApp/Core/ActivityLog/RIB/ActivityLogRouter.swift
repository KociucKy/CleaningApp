import SwiftUI
import NavigationKit

@MainActor
protocol ActivityLogRouter {
	func dismissScreen()
	func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@MainActor @Sendable () -> AnyView)?)
	func dismissAlert()
	func presentActivityLogEditView(
		completedTask: CompletedTask,
		onDismiss: (() -> Void)?
	)
}

extension CoreRouter: ActivityLogRouter {}
