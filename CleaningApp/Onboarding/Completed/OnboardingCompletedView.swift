import FulhamKit
import SwiftUI

// MARK: - OnboardingCompletedView

struct OnboardingCompletedView: View {
	// MARK: - Properties

	@State var presenter: OnboardingCompletedPresenter

	// MARK: - Body

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("onb_completed.title")
				.font(.largeTitle)
				.fontWeight(.semibold)
			Text("onb_completed.subtitle")
				.font(.title3)
				.fontWeight(.medium)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.padding(24)
		.safeAreaInset(edge: .bottom) {
			finishButton
				.padding(24)
		}
		.navigationBarHidden(true)
	}

	// MARK: - Finish Button

	private var finishButton: some View {
		Button {
			presenter.onFinishButtonPressed()
		} label: {
			Text("common.action.finish")
				.font(FKTypography.ctaLabel)
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.frame(height: 50)
		}
		.buttonStyle(.glassProminent)
	}
}
