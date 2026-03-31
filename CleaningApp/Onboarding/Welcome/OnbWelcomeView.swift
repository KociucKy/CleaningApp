import SwiftUI
import FulhamKit

struct OnbWelcomeView: View {
	// MARK: - Properties

	@State var presenter: OnbWelcomePresenter

	// MARK: - Body

	var body: some View {
		VStack(spacing: 16) {
			Spacer()
			titleSection
			Spacer()
		}
		.navigationBarHidden(true)
		.safeAreaInset(edge: .bottom) {
			getStartedButton
				.padding(.horizontal, 24)
		}
	}

	// MARK: - Title Section

	private var titleSection: some View {
		VStack(spacing: 8) {
			Text("CleaningApp")
				.font(.largeTitle)
				.fontWeight(.semibold)
			Text("Get started to set up your profile.")
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 32)
		}
	}

	// MARK: - Get Started Button

	private var getStartedButton: some View {
		Button {
			presenter.onGetStartedPressed()
		} label: {
			Text("Get started")
				.font(FKTypography.ctaLabel)
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.frame(height: 50)
		}
		.buttonStyle(.glassProminent)
	}
}

#Preview {
	let container = DevPreview.shared.container
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))

	RouterView { router in
		builder.welcomeView()
	}
}
