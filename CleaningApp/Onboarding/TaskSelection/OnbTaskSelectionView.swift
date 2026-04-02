import FulhamKit
import SwiftUI

// MARK: - OnbTaskSelectionView

@MainActor
struct OnbTaskSelectionView: View {
	// MARK: - Properties

	@State var presenter: OnbTaskSelectionPresenter

	// MARK: - Body

	var body: some View {
		ScrollView {
			LazyVStack(spacing: FKSpacing.large, pinnedViews: .sectionHeaders) {
				ForEach(presenter.selectedRooms) { room in
					roomSection(room)
				}
			}
			.padding(.horizontal, FKSpacing.large)
			.padding(.vertical, FKSpacing.large)
		}
		.navigationTitle("onb_task_selection.nav_title")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden()
		.safeAreaBar(edge: .bottom) {
			controlButtonsView
		}
	}

	// MARK: - SubViews

	private func roomSection(_ room: RoomType) -> some View {
		Section {
			let tasks = presenter.suggestedTasks(for: room)
			VStack(spacing: 0) {
				ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
					taskRow(task, room: room, isLast: index == tasks.count - 1)
				}
			}
			.clipShape(RoundedRectangle(cornerRadius: FKRadius.medium))
			.fkBorder(cornerRadius: FKRadius.medium, lineWidth: FKBorder.thin, color: Color(FKColor.Separator.default))
		} header: {
			roomSectionHeader(room)
		}
	}

	private func roomSectionHeader(_ room: RoomType) -> some View {
		HStack(spacing: FKSpacing.small) {
			Image(systemName: room.symbolName)
				.font(FKTypography.bodyBold)
				.foregroundStyle(Color.accentColor)
			Text(room.rawValue)
				.font(FKTypography.bodyBold)
				.foregroundStyle(FKColor.Label.primary)
			Spacer()
		}
		.padding(.vertical, FKSpacing.small)
		.background(.background)
	}

	private func taskRow(_ task: RoomTask, room: RoomType, isLast: Bool) -> some View {
		let isSelected = presenter.isTaskSelected(task, for: room)
		return Button {
			FKHaptics.selection()
			presenter.onTaskRowPressed(task, for: room)
		} label: {
			HStack(spacing: FKSpacing.medium) {
				VStack(alignment: .leading, spacing: FKSpacing.extraSmall) {
					Text(task.name)
						.font(FKTypography.body)
						.foregroundStyle(FKColor.Label.primary)
					Text(task.frequency.displayName)
						.font(FKTypography.caption)
						.foregroundStyle(FKColor.Label.secondary)
				}
				Spacer()
				Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
					.font(FKTypography.body)
					.foregroundStyle(isSelected ? Color.accentColor : Color(FKColor.Separator.default))
					.animation(.interactiveSpring, value: isSelected)
			}
			.padding(.horizontal, FKSpacing.medium)
			.padding(.vertical, FKSpacing.medium)
			.background(Color(FKColor.Background.primary))
			.overlay(alignment: .bottom) {
				if !isLast {
					Divider()
						.padding(.leading, FKSpacing.medium)
				}
			}
		}
		.buttonStyle(.plain)
	}

	private var controlButtonsView: some View {
		VStack(spacing: FKSpacing.medium) {
			Button {
				FKHaptics.impact(.medium)
				presenter.onNextButtonPressed()
			} label: {
				Text("common.action.next")
					.font(FKTypography.ctaLabel)
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 50)
			}
			.buttonStyle(.glassProminent)
			.padding([.horizontal, .top], FKSpacing.large)
			Button("common.action.skip", action: presenter.onSkipButtonPressed)
				.font(FKTypography.secondaryLabel)
				.foregroundStyle(FKColor.Label.secondary)
		}
	}
}

// MARK: - Preview

#Preview {
	let container = DevPreview.shared.container
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))

	RouterView { router in
		builder.taskSelectionView(router: router)
	}
}
