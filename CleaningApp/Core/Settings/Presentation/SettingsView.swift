import NavigationKit
import SwiftUI

struct SettingsView: View {
	// MARK: - Properties

	@State var presenter: SettingsPresenter

	// MARK: - Body

	var body: some View {
		Form {
			Section("Schedule") {
				Stepper(
					"Daily limit: \(presenter.dailyScheduleLimit) min",
					value: Binding(
						get: { presenter.dailyScheduleLimit },
						set: presenter.updateDailyScheduleLimit
					),
					in: 5 ... 120,
					step: 5
				)
			}
		}
			.navigationTitle("settings.nav_title")
			.toolbarTitleDisplayMode(.inlineLarge)
			.onAppear(perform: presenter.fetchSettings)
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let builder = CoreBuilder(interactor: CoreInteractor(container: container))

	return RouterView { router in
		builder.settingsView(router: router)
	}
}
