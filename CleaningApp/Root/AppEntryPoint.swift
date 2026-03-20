import SwiftUI

@main
struct AppEntryPoint: App {
	// MARK: - Properties

	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

	// MARK: - Body

	var body: some Scene {
		WindowGroup {
			AppViewBuilder(
				showOnboarding: delegate.appState.showOnboarding,
				mainView: { delegate.builder.build() },
				onboardingView: { delegate.onboardingBuilder.build() }
			)
		}
	}
}
