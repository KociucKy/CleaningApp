import FulhamKit
import SwiftUI

struct OnbControlButtonsView: View {
	let buttonLabel: LocalizedStringKey
	var showSkipButton: Bool = false
	var isPrimaryButtonDisabled = false
	let primaryAction: () -> Void
	var skipAction: (() -> Void)?

	@ScaledMetric private var buttonHeight: CGFloat = 50

	var body: some View {
		VStack(spacing: FKSpacing.medium) {
			Button {
				FKHaptics.impact(.medium)
				primaryAction()
			} label: {
				Text(buttonLabel)
					.font(FKTypography.ctaLabel)
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.frame(height: buttonHeight)
			}
			.buttonStyle(.glassProminent)
			.padding([.horizontal, .top], FKSpacing.large)
			.disabled(isPrimaryButtonDisabled)
			if let skipAction, showSkipButton {
				Button("common.action.skip", action: skipAction)
					.font(FKTypography.secondaryLabel)
					.foregroundStyle(FKColor.Label.secondary)
			}
		}
	}
}

#Preview {
	OnbControlButtonsView(
		buttonLabel: "common.action.next",
		showSkipButton: true,
		primaryAction: {},
		skipAction: {}
	)
}
