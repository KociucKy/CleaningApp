import SwiftUI

// MARK: - ScheduleTasksListView

@MainActor
struct ScheduleTasksListView: View {
	// MARK: - Properties
	
	let summary: ScheduleDaySummary
	let tasks: [ScheduleTaskRow]
	let onComplete: (ScheduleTaskRow) -> Void
	let onSkip: (ScheduleTaskRow) -> Void
	let onRetry: (ScheduleTaskRow) -> Void
	let onUncomplete: (ScheduleTaskRow) -> Void
	
	// MARK: - Body
	
	var body: some View {
		List {
			Section {
				ScheduleDaySummaryView(summary: summary)
					.removeListRowFormatting()
			}

			Section {
				ForEach(tasks) { task in
					taskCard(task)
				}
			}
		}
		.containerRelativeFrame(.horizontal)
		.animation(.snappy, value: tasks)
	}

	// MARK: - Views
	
	@ViewBuilder
	private func taskCard(_ task: ScheduleTaskRow) -> some View {
		taskCardContent(task)
			.contentShape(.rect)
			.overlay {
				if task.status == .planned || task.status == .completed {
					taskInteractionButton(task)
				}
			}
			.contextMenu {
				taskContextMenu(task)
			}
	}

	@ViewBuilder
	private func taskInteractionButton(_ task: ScheduleTaskRow) -> some View {
		Button {
			withAnimation(.snappy) {
				if task.status == .planned {
					onComplete(task)
				} else {
					onUncomplete(task)
				}
			}
		} label: {
			Rectangle()
				.fill(.clear)
				.contentShape(.rect)
		}
		.buttonStyle(.fkFade)
		.accessibilityLabel(task.name)
	}

	@ViewBuilder
	private func taskContextMenu(_ task: ScheduleTaskRow) -> some View {
		switch task.status {
		case .planned:
			Button(
				String(localized: .init(
					"schedule.action.skip",
					defaultValue: "Skip task"
				)),
				systemImage: "arrowshape.turn.up.right"
			) {
				withAnimation(.snappy) {
					onSkip(task)
				}
			}

		case .skipped:
			Button(
				String(localized: .init(
					"schedule.action.retry",
					defaultValue: "Retry"
				)),
				systemImage: "arrow.uturn.backward"
			) {
				withAnimation(.snappy) {
					onRetry(task)
				}
			}

		case .completed, .postponed, .cancelled:
			EmptyView()
		}
	}
	
	private func taskCardContent(_ task: ScheduleTaskRow) -> some View {
		ScheduleTaskCardView(
			task: task,
			onRetryButtonTapped: onRetry
		)
	}
}

// MARK: - Preview

#Preview {
	ScheduleTasksListView(
		summary: ScheduleDaySummary(
			weekdayName: "Monday",
			completionText: "0/1",
			taskDescription: "1 task • 15 min planned",
			completedTaskCount: 0,
			progressTotal: 1,
			showsEmptyState: false
		),
		tasks: [
			ScheduleTaskRow(
				id: UUID(),
				name: "Vacuum the floor",
				roomName: "Living Room",
				duration: 15,
				symbolName: "sofa.fill",
				status: .planned
			)
		],
		onComplete: { _ in },
		onSkip: { _ in },
		onRetry: { _ in },
		onUncomplete: { _ in }
	)
}
