import FulhamKit
import SwiftUI

// MARK: - RoomsDetailsTaskCompletionView

struct RoomsDetailsTaskCompletionView: View {
	// MARK: - Properties

	@State private var presenter: RoomsDetailsTaskCompletionPresenter
	let taskName: String

	init(
		presenter: RoomsDetailsTaskCompletionPresenter,
		taskName: String
	) {
		self._presenter = State(wrappedValue: presenter)
		self.taskName = taskName
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

				Text(taskName)
					.font(FKTypography.footnoteEmphasis)
					.multilineTextAlignment(.center)

				Text("Estimated (estimatedDuration) minutes")
					.font(FKTypography.secondaryLabel)
					.foregroundStyle(.secondary)
			}
			VStack(spacing: FKSpacing.medium) {
				presetRow(title: "Just now", subtitle: "A moment ago", offset: 0, icon: "bolt.fill")
				presetRow(title: "15 minutes ago", subtitle: "A quick cleaning session", offset: -15 * 60, icon: "clock")
				presetRow(title: "1 hour ago", subtitle: "Earlier today", offset: -60 * 60, icon: "clock.arrow.circlepath")
			}
			dateAndTimePicker
			Spacer()
			completionAction
		}
	}

	private func presetRow(
		title: String,
		subtitle: String,
		offset: TimeInterval,
		icon: String
	) -> some View {
		Button {
			presenter.completedAt = Date().addingTimeInterval(offset)
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
				if abs(presenter.completedAt.timeIntervalSinceNow - offset) < 5 {
					Image(systemName: "checkmark")
						.font(FKTypography.ctaLabel)
						.fontWeight(.bold)
				}
			}
			.padding()
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
		.background(.background, in: RoundedRectangle(cornerRadius: FKRadius.medium))
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
		Button("Mark as completed") {}
			.buttonStyle(.glassProminent)
			.controlSize(.large)
			.frame(maxWidth: .infinity)
			.accessibilityHint("Completion is not wired up yet")
	}
}

// MARK: - Preview

#Preview {
	let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
	let taskName = "Wipe the floor"
	return RouterView { router in
		builder.roomsDetailsTaskCompletionView(router: router, taskName: taskName)
	}
}
