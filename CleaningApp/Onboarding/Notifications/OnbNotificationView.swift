import SwiftUI
import FulhamKit

struct OnbNotificationView: View {
	@State var presenter: OnbNotificationPresenter

	var body: some View {
		VStack {
			Spacer()
			Text("Notifcation Enabling View")
				.font(.largeTitle)
			Spacer()
		}
		.safeAreaBar(edge: .bottom) {
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
		}
	}
}

#Preview {
	let container = DevPreview.shared.container
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))

	RouterView { router in
		builder.notificationView(router: router)
	}
}
