import SwiftUI

// MARK: - ScheduleTasksListView

@MainActor
struct ScheduleTasksListView: View {
	// MARK: - Properties
	
	let summary: ScheduleDaySummary
	let tasks: [ScheduleTaskRow]
	let onComplete: (ScheduleTaskRow) -> Void
	let onSkip: (ScheduleTaskRow) -> Void
	let onUndoSkip: (ScheduleTaskRow) -> Void
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
	}
	
	// MARK: - Views
	
	@ViewBuilder
	private func taskCard(_ task: ScheduleTaskRow) -> some View {
		switch task.status {
		case .planned:
			Button {
				withAnimation {
					onComplete(task)
				}
			} label: {
				taskCardContent(task)
					.contentShape(.rect)
			}
			.buttonStyle(.fkFade)
			.contextMenu {
				Button(
					String(localized: .init(
						"schedule.action.skip",
						defaultValue: "Skip task"
					)),
					systemImage: "arrowshape.turn.up.right"
				) {
					withAnimation {
						onSkip(task)
					}
				}
			}
			
		case .skipped:
			taskCardContent(task)
				.contextMenu {
					Button(
						String(localized: .init(
							"schedule.action.undo_skip",
							defaultValue: "Undo Skip"
						)),
						systemImage: "arrow.uturn.backward"
					) {
						withAnimation {
							onUndoSkip(task)
						}
					}
				}
			
		case .completed:
			Button {
				withAnimation {
					onUncomplete(task)
				}
			} label: {
				taskCardContent(task)
					.contentShape(.rect)
			}
			
		case .postponed, .cancelled:
			taskCardContent(task)
		}
	}
	
	private func taskCardContent(_ task: ScheduleTaskRow) -> some View {
		ScheduleTaskCardView(
			task: task,
			onUndoSkipButtonTapped: onUndoSkip
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
		onUndoSkip: { _ in },
		onUncomplete: { _ in }
	)
}
