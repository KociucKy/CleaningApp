import NavigationKit
import SwiftUI

struct DevSettingsView: View {
	// MARK: - Properties

	@State var presenter: DevSettingsPresenter

	// MARK: - Body

	var body: some View {
		List {
			Button("dev_settings.button.app_store_review", action: presenter.pushReviewKitDebugView)
			Button("dev_settings.button.device_info", action: presenter.pushDeviceDebugView)
			Button("dev_settings.button.local_notifications", action: presenter.pushLocalNotificationDebugView)
			Button("dev_settings.button.user_defaults", action: presenter.pushUserDefaultsDebugView)
		}
		.navigationTitle("dev_settings.nav_title")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("common.action.close") {
					presenter.dismiss()
				}
			}
		}
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.devSettingsView(router: router)
	}
}
