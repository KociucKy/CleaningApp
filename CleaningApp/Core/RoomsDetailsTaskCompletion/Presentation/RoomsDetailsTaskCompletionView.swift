import FulhamKit
import SwiftUI

struct RoomsDetailsTaskCompletionProps {
	let taskId: UUID
	let taskName: String
}

struct RoomsDetailsTaskCompletionView: View {
	// MARK: - Constants

	private enum Constants {
		static let zeroOffset: CGFloat = 0
		static let visibleOpacity: Double = 1
		static let hiddenOpacity: Double = 0
		static let symbolEffectDelay: Double = 0.12
		static let contentInitialOffset: CGFloat = 12
		static let presetIconWidth: CGFloat = 24
		static let borderLineWidth: CGFloat = 1
		static let contentAnimationDuration: Double = 0.26
		static let firstPresetAnimationDelay: Double = 0.1
		static let secondPresetAnimationDelay: Double = 0.14
		static let thirdPresetAnimationDelay: Double = 0.18
		static let datePickerAnimationDelay: Double = 0.24
		static let completionActionAnimationDelay: Double = 0.3
		static let justNowOffset: TimeInterval = 0
		static let fifteenMinutesAgoOffset: TimeInterval = -15 * 60
		static let oneHourAgoOffset: TimeInterval = -60 * 60
	}

	// MARK: - Properties

	@State private var presenter: RoomsDetailsTaskCompletionPresenter
	let props: RoomsDetailsTaskCompletionProps

	init(
		presenter: RoomsDetailsTaskCompletionPresenter,
		props: RoomsDetailsTaskCompletionProps
	) {
		self._presenter = State(wrappedValue: presenter)
		self.props = props
	}

	// MARK: - Body

	var body: some View {
		VStack(spacing: FKSpacing.extraLarge) {
			RoomsDetailsTaskCompletionHeroView(
				taskName: props.taskName,
				hasAppeared: presenter.hasAppeared,
				animateSymbol: presenter.animateSymbol
			)
			VStack(spacing: FKSpacing.large) {
				presetRow(title: "rooms_details_task_completion.just_now", subtitle: "rooms_details_task_completion.just_now_subtitle", offset: Constants.justNowOffset, icon: "bolt.fill", entranceDelay: Constants.firstPresetAnimationDelay)
				presetRow(title: "rooms_details_task_completion.fifteen_minutes", subtitle: "rooms_details_task_completion.fifteen_minutes_subtitle", offset: Constants.fifteenMinutesAgoOffset, icon: "clock", entranceDelay: Constants.secondPresetAnimationDelay)
				presetRow(title: "rooms_details_task_completion.one_hour", subtitle: "rooms_details_task_completion.one_hour_subtitle", offset: Constants.oneHourAgoOffset, icon: "clock.arrow.circlepath", entranceDelay: Constants.thirdPresetAnimationDelay)
			}
			dateAndTimePicker
				.opacity(presenter.hasAppeared ? Constants.visibleOpacity : Constants.hiddenOpacity)
				.offset(y: presenter.hasAppeared ? Constants.zeroOffset : Constants.contentInitialOffset)
				.animation(.easeOut(duration: Constants.contentAnimationDuration).delay(Constants.datePickerAnimationDelay), value: presenter.hasAppeared)
			completionAction
				.opacity(presenter.hasAppeared ? Constants.visibleOpacity : Constants.hiddenOpacity)
				.offset(y: presenter.hasAppeared ? Constants.zeroOffset : Constants.contentInitialOffset)
				.animation(.easeOut(duration: Constants.contentAnimationDuration).delay(Constants.completionActionAnimationDelay), value: presenter.hasAppeared)
		}
		.padding(.horizontal, FKSpacing.large)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("rooms_details_task_completion.cancel", systemImage: "xmark", role: .cancel, action: presenter.onCloseButtonTapped)
			}
		}
		.onAppear {
			presenter.onAppear(animationDelay: Constants.symbolEffectDelay)
		}
	}

	private func presetRow(
		title: LocalizedStringKey,
		subtitle: LocalizedStringKey,
		offset: TimeInterval,
		icon: String,
		entranceDelay: Double
	) -> some View {
		Button {
			presenter.onPresetSelected(offset: offset)
		} label: {
			HStack(spacing: FKSpacing.large) {
				Image(systemName: icon)
					.frame(width: Constants.presetIconWidth)
				VStack(alignment: .leading) {
					Text(title)
						.font(FKTypography.ctaLabel)
				}
				Spacer()
				Image(systemName: "checkmark")
					.font(FKTypography.ctaLabel)
					.fontWeight(.bold)
					.opacity(presenter.selectedPresetOffset == offset ? Constants.visibleOpacity : Constants.hiddenOpacity)
			}
			.contentShape(.capsule)
		}
		.buttonStyle(.plain)
		.padding()
		.opacity(presenter.hasAppeared ? Constants.visibleOpacity : Constants.hiddenOpacity)
		.offset(y: presenter.hasAppeared ? Constants.zeroOffset : Constants.contentInitialOffset)
		.animation(.easeOut(duration: Constants.contentAnimationDuration).delay(entranceDelay), value: presenter.hasAppeared)
		.overlay {
			RoundedRectangle(cornerRadius: FKRadius.medium)
				.fill(.clear)
				.strokeBorder(
					presenter.selectedPresetOffset == offset ? FKColor.Label.primary : FKColor.Label.tertiary,
					lineWidth: Constants.borderLineWidth
				)
		}
	}

	private var dateAndTimePicker: some View {
		DatePicker(
			"rooms_details_task_completion.completed_at",
			selection: $presenter.completedAt,
			displayedComponents: [.date, .hourAndMinute]
		)
		.datePickerStyle(.compact)
	}

	private var completionAction: some View {
		Button("rooms_details_task_completion.mark_as_completed") {
			presenter.onMarkAsCompletedButtonTapped(taskId: props.taskId)
		}
		.buttonStyle(.glassProminent)
		.controlSize(.large)
		.frame(maxWidth: .infinity)
		.accessibilityHint(String(localized: "rooms_details_task_completion.completion_not_wired"))
	}
}

// MARK: - Preview

#Preview {
	let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
	let props = RoomsDetailsTaskCompletionProps(
		taskId: UUID(),
		taskName: "Wipe the floor"
	)
	return RouterView { router in
		builder.roomsDetailsTaskCompletionView(router: router, props: props)
	}
}
