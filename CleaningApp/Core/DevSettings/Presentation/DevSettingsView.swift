import NavigationKit
import SwiftUI

struct DevSettingsView: View {
	// MARK: - Properties

	@State var presenter: DevSettingsPresenter

	// MARK: - Body

	var body: some View {
		List {
			Button("App Store Review", action: presenter.pushReviewKitDebugView)
			Button("Device Info", action: presenter.pushDeviceDebugView)
			Button("Local Notifications", action: presenter.pushLocalNotificationDebugView)
			Button("UserDefaults", action: presenter.pushUserDefaultsDebugView)
		}
		.navigationTitle("Dev Settings")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Close") {
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
