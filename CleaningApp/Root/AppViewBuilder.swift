import SwiftUI

// MARK: - AppViewBuilder

struct AppViewBuilder<MainView: View, OnboardingView: View>: View {
	// MARK: - Properties

	var showOnboarding: Bool
	var mainView: () -> MainView
	var onboardingView: () -> OnboardingView
	var onOnboardingDismissed: (() -> Void)?

	// MARK: - Body

	var body: some View {
		ZStack {
			mainView()

			if showOnboarding {
				onboardingView()
					.transition(.move(edge: .leading))
					.zIndex(1)
			}
		}
		.animation(.smooth, value: showOnboarding)
		.onChange(of: showOnboarding) { old, new in
			if old == true, new == false {
				onOnboardingDismissed?()
			}
		}
	}
}
