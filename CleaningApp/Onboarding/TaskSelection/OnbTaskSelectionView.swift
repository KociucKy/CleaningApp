import FulhamKit
import SwiftUI

struct OnbTaskSelectionView: View {
	// MARK: - Constants

	private enum Constants {
		static let unselectedTaskRowOpacity: CGFloat = 0.3
	}

	// MARK: - RoomSection

	private enum RoomSection: Hashable, Identifiable {
		case predefined(RoomType)
		case custom(CustomRoomSelection)

		var id: String {
			switch self {
			case let .predefined(room):
				"predefined_\(room.rawValue)"
			case let .custom(customRoom):
				"custom_\(customRoom.id.uuidString)"
			}
		}

		var icon: String {
			switch self {
			case let .predefined(room):
				room.symbolName
			case let .custom(customRoom):
				customRoom.icon
			}
		}

		var name: String {
			switch self {
			case let .predefined(room):
				room.localizedName
			case let .custom(customRoom):
				customRoom.name
			}
		}
	}

	// MARK: - Properties

	@State var presenter: OnbTaskSelectionPresenter
	@State private var collapsedRooms: Set<String> = []

	private var allRoomSections: [RoomSection] {
		let predefined = presenter.selectedRooms.map { RoomSection.predefined($0) }
		let custom = presenter.selectedCustomRooms.map { RoomSection.custom($0) }
		return predefined + custom
	}

	// MARK: - Body

	var body: some View {
		ScrollView {
			LazyVStack(spacing: FKSpacing.medium) {
				ForEach(Array(allRoomSections.enumerated()), id: \.element.id) { index, section in
					roomSection(section, index: index)
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
		.onAppear(perform: presenter.animateEntrance)
	}

	// MARK: - SubViews

	private func roomSection(_ section: RoomSection, index: Int) -> some View {
		let isCollapsed = collapsedRooms.contains(section.id)
		let isVisible = index < presenter.visibleSectionCount
		let tasks = tasksForSection(section)
		let lastTaskId = tasks.last?.id

		return VStack(spacing: 0) {
			roomSectionHeader(section, isCollapsed: isCollapsed)
			if !isCollapsed {
				VStack(spacing: FKSpacing.medium) {
					Divider()
					if tasks.isEmpty {
						emptyTasksPlaceholder()
					} else {
						ForEach(tasks) { task in
							taskRow(task, section: section)
							if task.id != lastTaskId {
								Divider()
							}
						}
					}
					Divider()
					addCustomTaskButton(for: section)
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

	private func roomSectionHeader(_ section: RoomSection, isCollapsed: Bool) -> some View {
		Button {
			FKHaptics.selection()
			withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
				if isCollapsed {
					collapsedRooms.remove(section.id)
				} else {
					collapsedRooms.insert(section.id)
				}
			}
		} label: {
			HStack(spacing: FKSpacing.small) {
				Image(systemName: section.icon)
					.font(FKTypography.bodyBold)
					.foregroundStyle(Color.accentColor)
					.accessibilityHidden(true)
				Text(section.name)
					.font(FKTypography.bodyBold)
					.foregroundStyle(FKColor.Label.primary)
				Spacer()
				if isCollapsed {
					let count = taskCountForSection(section)
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

	private func taskRow(_ task: RoomTask, section: RoomSection) -> some View {
		let isSelected = isTaskSelected(task, in: section)
		let showDeleteButton = shouldShowDeleteButton(for: task, in: section)

		return HStack(spacing: FKSpacing.medium) {
			Button {
				FKHaptics.selection()
				toggleTask(task, in: section)
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

			if showDeleteButton {
				Button {
					FKHaptics.selection()
					deleteTask(task, from: section)
				} label: {
					Image(systemName: "xmark.circle.fill")
						.font(FKTypography.sectionHeader)
						.foregroundStyle(FKColor.Label.tertiary)
				}
				.buttonStyle(.plain)
				.accessibilityLabel(Text("common.action.delete"))
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

	private func addCustomTaskButton(for section: RoomSection) -> some View {
		Button {
			FKHaptics.selection()
			addCustomTask(for: section)
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

	private func emptyTasksPlaceholder() -> some View {
		Label("onb_task_selection.empty_tasks_placeholder", systemImage: "rectangle.stack.slash.fill")
			.font(FKTypography.caption)
			.foregroundStyle(FKColor.Label.secondary)
			.frame(maxWidth: .infinity)
			.padding(.vertical, FKSpacing.small)
	}

	// MARK: - Helpers

	private func tasksForSection(_ section: RoomSection) -> [RoomTask] {
		switch section {
		case let .predefined(room):
			presenter.allTasks(for: room)
		case let .custom(customRoom):
			presenter.customRoomTasks(customRoom)
		}
	}

	private func taskCountForSection(_ section: RoomSection) -> Int {
		switch section {
		case let .predefined(room):
			presenter.selectedTaskCount(for: room)
		case let .custom(customRoom):
			presenter.selectedCustomRoomTaskCount(customRoom)
		}
	}

	private func isTaskSelected(_ task: RoomTask, in section: RoomSection) -> Bool {
		switch section {
		case let .predefined(room):
			presenter.isTaskSelected(task, for: room)
		case let .custom(customRoom):
			presenter.isCustomRoomTaskSelected(task, in: customRoom)
		}
	}

	private func shouldShowDeleteButton(for task: RoomTask, in section: RoomSection) -> Bool {
		switch section {
		case let .predefined(room):
			presenter.isCustomTask(task, for: room)
		case .custom:
			true // All tasks in custom rooms are custom
		}
	}

	private func toggleTask(_ task: RoomTask, in section: RoomSection) {
		switch section {
		case let .predefined(room):
			presenter.onTaskRowPressed(task, for: room)
		case let .custom(customRoom):
			presenter.onCustomRoomTaskRowPressed(task, in: customRoom)
		}
	}

	private func deleteTask(_ task: RoomTask, from section: RoomSection) {
		switch section {
		case let .predefined(room):
			presenter.onDeleteCustomTask(task, for: room)
		case let .custom(customRoom):
			presenter.onDeleteCustomRoomTask(task, from: customRoom)
		}
	}

	private func addCustomTask(for section: RoomSection) {
		switch section {
		case let .predefined(room):
			presenter.onAddCustomTaskButtonPressed(for: room)
		case let .custom(customRoom):
			presenter.onAddCustomTaskButtonPressed(for: customRoom)
		}
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
