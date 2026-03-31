import SwiftUI

// MARK: - AppViewBuilder

struct AppViewBuilder<MainView: View, OnboardingView: View>: View {
	// MARK: - Properties

	var showOnboarding: Bool
	var mainView: () -> MainView
	var onboardingView: () -> OnboardingView

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
	}
}
