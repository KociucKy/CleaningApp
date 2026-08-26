import FulhamKit
import SwiftUI

struct OnbPaywallView: View {
	@State var presenter: OnbPaywallPresenter

	var body: some View {
		VStack {
			Spacer()
			Text("Paywall")
				.font(.largeTitle)
			Spacer()
		}
		.navigationTitle("")
		.navigationBarTitleDisplayMode(.inline)
		.safeAreaBar(edge: .bottom) {
			VStack {
				Button {
					presenter.onNextButtonPressed()
				} label: {
					Text("Next")
						.font(FKTypography.ctaLabel)
						.foregroundStyle(.white)
						.frame(maxWidth: .infinity)
						.frame(height: 50)
				}
				.buttonStyle(.glassProminent)
				.padding([.horizontal, .top], FKSpacing.large)
				OnbProgressView(stage: .paywall)
			}
		}
	}
}

#Preview {
	let container = DevPreview.shared.container
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))

	RouterView { router in
		builder.paywallView(router: router)
	}
}
