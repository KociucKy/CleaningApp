import SwiftUI
import FulhamKit

struct RoomsDetailsTaskCompletionHeroView: View {
	private enum Constants {
		static let heroIconSize: CGFloat = 48
		static let heroInitialScale: CGFloat = 0.72
		static let identityScale: CGFloat = 1
		static let visibleOpacity: Double = 1
		static let hiddenOpacity: Double = 0
		static let heroAnimationResponse: Double = 0.28
		static let heroAnimationDamping: Double = 0.78
		static let symbolEffectSpeed: Double = 0.85
		static let zeroOffset: CGFloat = 0
		static let taskNameLineLimit = 1
		static let taskNameInitialOffset: CGFloat = 8
		static let textAnimationDuration: Double = 0.22
		static let taskTitleAnimationDelay: Double = 0.04
		static let taskNameAnimationDelay: Double = 0.08
	}

	var taskName: String
	var hasAppeared: Bool
	var animateSymbol: Bool

	var body: some View {
		VStack(spacing: FKSpacing.default) {
			Image(systemName: "checkmark.circle.fill")
				.font(.system(size: Constants.heroIconSize))
				.symbolRenderingMode(.hierarchical)
				.foregroundStyle(.green)
				.scaleEffect(hasAppeared ? Constants.identityScale : Constants.heroInitialScale)
				.opacity(hasAppeared ? Constants.visibleOpacity : Constants.hiddenOpacity)
				.animation(.spring(response: Constants.heroAnimationResponse, dampingFraction: Constants.heroAnimationDamping), value: hasAppeared)
				.symbolEffect(.bounce, options: .speed(Constants.symbolEffectSpeed), value: animateSymbol)

			Text("rooms_details_task_completion.title")
				.font(FKTypography.cardTitle)
				.fontWeight(.bold)
				.opacity(hasAppeared ? Constants.visibleOpacity : Constants.hiddenOpacity)
				.offset(y: hasAppeared ? Constants.zeroOffset : Constants.taskNameInitialOffset)
				.animation(.easeOut(duration: Constants.textAnimationDuration).delay(Constants.taskTitleAnimationDelay), value: hasAppeared)

			Text(taskName)
				.font(FKTypography.secondaryLabel)
				.multilineTextAlignment(.center)
				.lineLimit(Constants.taskNameLineLimit)
				.opacity(hasAppeared ? Constants.visibleOpacity : Constants.hiddenOpacity)
				.offset(y: hasAppeared ? Constants.zeroOffset : Constants.taskNameInitialOffset)
				.animation(.easeOut(duration: Constants.textAnimationDuration).delay(Constants.taskNameAnimationDelay), value: hasAppeared)
		}
	}
}

#Preview {
	RoomsDetailsTaskCompletionHeroView(
		taskName: "Wipe the floor",
		hasAppeared: true,
		animateSymbol: true
	)
}
