import FulhamKit
import SwiftUI

struct OnbLabelRowView: View {
	private enum Constants {
		static let symbolWidth: CGFloat = 32
	}

	let symbol: String
	let title: LocalizedStringKey
	let description: LocalizedStringKey

	var body: some View {
		HStack(spacing: FKSpacing.large) {
			Image(systemName: symbol)
				.font(FKTypography.sectionHeader)
				.fontWeight(.regular)
				.foregroundStyle(Color.accentColor)
				.symbolRenderingMode(.palette)
				.frame(width: Constants.symbolWidth)
				.accessibilityHidden(true)
			VStack(alignment: .leading, spacing: FKSpacing.extraSmall) {
				Text(title)
					.font(FKTypography.bodyBold)
					.foregroundStyle(FKColor.Label.primary)
				Text(description)
					.font(FKTypography.caption)
					.foregroundStyle(FKColor.Label.secondary)
			}
			Spacer()
		}
		.accessibilityElement(children: .combine)
	}
}

#Preview {
	OnbLabelRowView(
		symbol: "bell.badge.fill",
		title: "onb_notification.benefit.reminders.title",
		description: "onb_notification.benefit.reminders.description"
	)
	.padding(.horizontal)
}
