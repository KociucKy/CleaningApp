import FulhamKit
import SwiftUI

struct OnbTaskSelectionView: View {
	// MARK: - Constants

	private enum Constants {
		static let unselectedTaskRowOpacity: CGFloat = 0.3
	}

	// MARK: - Properties

	@State var presenter: OnbTaskSelectionPresenter
	@State private var collapsedRooms: Set<RoomType> = []
	@State private var showingCustomTaskSheet = false
	@State private var selectedRoomForCustomTask: RoomType?

	// MARK: - Body

	var body: some View {
		ScrollView {
			LazyVStack(spacing: FKSpacing.medium) {
				ForEach(Array(presenter.selectedRooms.enumerated()), id: \.element) { index, room in
					roomSection(room, index: index)
				}
			}
			.padding(.horizontal, FKSpacing.large)
			.padding(.top, FKSpacing.large)
		}
		.background(FKColor.Background.primary)
		.navigationTitle("onb_task_selection.nav_title")
		.navigationBarTitleDisplayMode(.inline)
		.safeAreaBar(edge: .bottom) {
			controlButtonsView
				.opacity(presenter.buttonVisible ? 1 : 0)
				.offset(y: presenter.buttonVisible ? 0 : 16)
		}
		.sheet(isPresented: $showingCustomTaskSheet) {
			if let room = selectedRoomForCustomTask {
				OnbAddCustomTaskSheetView(
					isPresented: $showingCustomTaskSheet,
					roomType: room,
					onAdd: { task in
						presenter.onAddCustomTask(task, for: room)
					}
				)
			}
		}
		.onAppear(perform: presenter.animateEntrance)
	}

	// MARK: - SubViews

	private func roomSection(_ room: RoomType, index: Int) -> some View {
		let isCollapsed = collapsedRooms.contains(room)
		let isVisible = index < presenter.visibleSectionCount
		return VStack(spacing: 0) {
			roomSectionHeader(room, isCollapsed: isCollapsed)
			if !isCollapsed {
				let tasks = presenter.allTasks(for: room)
				let lastTaskId = tasks.last?.id
				VStack(spacing: FKSpacing.medium) {
					Divider()
					ForEach(tasks) { task in
						taskRow(task, room: room)
						if task.id != lastTaskId {
							Divider()
						}
					}
					Divider()
					addCustomTaskButton(for: room)
				}
				.padding(.top, FKSpacing.small)
				.transition(
					.opacity.combined(with: .scale(scale: 0.96, anchor: .top))
				)
			}
		}
		.padding(FKSpacing.medium)
		.background(FKColor.Background.canvas, in: RoundedRectangle(cornerRadius: FKRadius.medium))
		.opacity(isVisible ? 1 : 0)
		.offset(y: isVisible ? 0 : 20)
	}

	private func roomSectionHeader(_ room: RoomType, isCollapsed: Bool) -> some View {
		Button {
			FKHaptics.selection()
			withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
				if isCollapsed {
					collapsedRooms.remove(room)
				} else {
					collapsedRooms.insert(room)
				}
			}
		} label: {
			HStack(spacing: FKSpacing.small) {
				Image(systemName: room.symbolName)
					.font(FKTypography.bodyBold)
					.foregroundStyle(Color.accentColor)
					.accessibilityHidden(true)
				Text(room.localizedName)
					.font(FKTypography.bodyBold)
					.foregroundStyle(FKColor.Label.primary)
				Spacer()
				if isCollapsed {
					let count = presenter.selectedTaskCount(for: room)
					Text(
						String.localizedStringWithFormat(
							String(localized: "onb_task_selection.selected_tasks_count"),
							Int64(count)
						)
					)
					.font(FKTypography.caption)
					.foregroundStyle(FKColor.Label.secondary)
					.transition(.opacity.combined(with: .scale(scale: 0.9)))
					.accessibilityHidden(true)
				}
				Image(systemName: "chevron.down")
					.font(FKTypography.caption)
					.foregroundStyle(FKColor.Label.secondary)
					.rotationEffect(.degrees(isCollapsed ? -90 : 0))
					.animation(.spring(response: 0.35, dampingFraction: 0.8), value: isCollapsed)
					.accessibilityHidden(true)
			}
			.padding(.vertical, FKSpacing.small)
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
	}

	private func taskRow(_ task: RoomTask, room: RoomType) -> some View {
		let isSelected = presenter.isTaskSelected(task, for: room)
		let isCustom = presenter.isCustomTask(task, for: room)
		return HStack(spacing: FKSpacing.medium) {
			Button {
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
					.opacity(isSelected ? 1 : Constants.unselectedTaskRowOpacity)
					Spacer()
					Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
						.font(FKTypography.sectionHeader)
						.foregroundStyle(isSelected ? Color.accentColor : Color(FKColor.Separator.default))
						.contentTransition(.symbolEffect(.replace))
						.accessibilityHidden(true)
				}
				.contentShape(.rect)
			}
			.accessibilityAddTraits(isSelected ? .isSelected : [])
			.buttonStyle(.fkFade)

			if isCustom {
				Button {
					FKHaptics.selection()
					presenter.onDeleteCustomTask(task, for: room)
				} label: {
					Image(systemName: "xmark.circle.fill")
						.font(FKTypography.sectionHeader)
						.foregroundStyle(FKColor.Label.tertiary)
				}
				.buttonStyle(.plain)
				.accessibilityLabel("common.action.delete")
			}
		}
	}

	private var controlButtonsView: some View {
		OnbControlButtonsView(
			buttonLabel: "common.action.next",
			showSkipButton: true,
			primaryAction: presenter.onNextButtonPressed,
			skipAction: presenter.onSkipButtonPressed
		)
	}

	private func addCustomTaskButton(for room: RoomType) -> some View {
		Button {
			FKHaptics.selection()
			selectedRoomForCustomTask = room
			showingCustomTaskSheet = true
		} label: {
			HStack(spacing: FKSpacing.small) {
				Image(systemName: "plus.circle.fill")
					.font(FKTypography.body)
					.foregroundStyle(Color.accentColor)
				Text("onb_task_selection.action.add_custom_task")
					.font(FKTypography.body)
					.foregroundStyle(Color.accentColor)
			}
			.frame(maxWidth: .infinity)
			.padding(.vertical, FKSpacing.small)
			.contentShape(.rect)
		}
		.buttonStyle(.fkFade)
	}
}

// MARK: - Preview

#Preview {
	let devPreview = DevPreview()
	let _ = {
		devPreview.onboardingFlowState.toggleRoom(.kitchen)
		devPreview.onboardingFlowState.toggleRoom(.bedroom)
	}()
	let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: devPreview.container))

	RouterView { router in
		builder.taskSelectionView(router: router)
	}
}
