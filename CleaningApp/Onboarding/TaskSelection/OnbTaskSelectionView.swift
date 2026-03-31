import SwiftUI
import FulhamKit

struct OnbTaskSelectionView: View {
	@State var presenter: OnbTaskSelectionPresenter

	var body: some View {
		VStack {
			Spacer()
			Text("Task Selection View")
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
		builder.taskSelectionView(router: router)
	}
}
