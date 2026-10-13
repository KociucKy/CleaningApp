import NavigationKit
import SwiftUI

@MainActor
protocol ActivityLogRouter {
	func dismissScreen()
	func showDeleteConfirmation(onConfirm: @escaping @MainActor @Sendable () -> Void)
	func showError(message: String)
	func presentActivityLogEditView(
		completedTask: CompletedTask,
		onDismiss: (() -> Void)?
	)
}

extension CoreRouter: ActivityLogRouter {
	func showDeleteConfirmation(onConfirm: @escaping @MainActor @Sendable () -> Void) {
		router.showAlert(
			.alert,
			title: String(localized: "activity_log.delete.confirmation"),
			subtitle: nil,
			buttons: { @MainActor in
				Group {
					Button("common.action.delete", role: .destructive) {
						router.dismissAlert()
						onConfirm()
					}
					Button("common.action.cancel", role: .cancel, action: router.dismissAlert)
				}.any()
			}
		)
	}

	func showError(message: String) {
		router.showAlert(
			.alert,
			title: message,
			subtitle: nil,
			buttons: nil
		)
	}
}
