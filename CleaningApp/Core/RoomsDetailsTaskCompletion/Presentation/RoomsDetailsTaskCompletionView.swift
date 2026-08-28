import FulhamKit
import SwiftUI

struct RoomsDetailsTaskCompletionProps {
	let taskId: UUID
	let taskName: String
}

struct RoomsDetailsTaskCompletionView: View {
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
			VStack(spacing: FKSpacing.default) {
				Image(systemName: "checkmark.circle.fill")
					.font(.system(size: 48))
					.symbolRenderingMode(.hierarchical)
					.foregroundStyle(.green)

				Text("Task completed")
					.font(FKTypography.cardTitle)
					.fontWeight(.bold)

				Text(props.taskName)
					.font(FKTypography.secondaryLabel)
					.multilineTextAlignment(.center)
					.lineLimit(1)
			}
			VStack(spacing: FKSpacing.large) {
				presetRow(title: "Just now", subtitle: "A moment ago", offset: 0, icon: "bolt.fill")
				presetRow(title: "15 minutes ago", subtitle: "A quick cleaning session", offset: -15 * 60, icon: "clock")
				presetRow(title: "1 hour ago", subtitle: "Earlier today", offset: -60 * 60, icon: "clock.arrow.circlepath")
			}
			dateAndTimePicker
			completionAction
		}
		.padding(.horizontal, FKSpacing.large)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel", systemImage: "xmark", role: .cancel, action: presenter.onCloseButtonTapped)
			}
		}
	}

	private func presetRow(
		title: String,
		subtitle: String,
		offset: TimeInterval,
		icon: String
	) -> some View {
		Button {
			withTransaction(Transaction(animation: nil)) {
				presenter.selectedPresetOffset = offset
				presenter.completedAt = Date().addingTimeInterval(offset)
			}
			DispatchQueue.main.async {
				FKHaptics.impact(.light)
			}
		} label: {
			HStack(spacing: FKSpacing.large) {
				Image(systemName: icon)
					.frame(width: 24)
				VStack(alignment: .leading) {
					Text(title)
						.font(FKTypography.ctaLabel)
					Text(subtitle)
						.font(FKTypography.caption)
						.foregroundStyle(.secondary)
				}
				Spacer()
				Image(systemName: "checkmark")
					.font(FKTypography.ctaLabel)
					.fontWeight(.bold)
					.opacity(presenter.selectedPresetOffset == offset ? 1 : 0)
			}
			.contentShape(.capsule)
		}
		.buttonStyle(.plain)
		.padding()
		.overlay {
			RoundedRectangle(cornerRadius: FKRadius.medium)
				.fill(.clear)
				.strokeBorder(
					presenter.selectedPresetOffset == offset ? FKColor.Label.primary : FKColor.Label.tertiary,
					lineWidth: 1
				)
		}
	}

	private var dateAndTimePicker: some View {
		DatePicker(
			"Completed at",
			selection: $presenter.completedAt,
			displayedComponents: [.date, .hourAndMinute]
		)
		.datePickerStyle(.compact)
	}

	private var completionAction: some View {
		Button("Mark as completed") {
			presenter.onMarkAsCompletedButtonTapped(taskId: props.taskId)
		}
		.buttonStyle(.glassProminent)
		.controlSize(.large)
		.frame(maxWidth: .infinity)
		.accessibilityHint("Completion is not wired up yet")
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
