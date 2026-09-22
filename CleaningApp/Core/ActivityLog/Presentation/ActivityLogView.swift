import SwiftUI
import FulhamKit

// MARK: - ActivityLogView

struct ActivityLogView: View {
	// MARK: - Properties
	
	@State private var presenter: ActivityLogPresenter
	
	// MARK: - Init
	
	init(presenter: ActivityLogPresenter) {
		_presenter = State(initialValue: presenter)
	}
	
	// MARK: - Body
	
	var body: some View {
		Group {
			switch presenter.state {
			case .isLoading:
				ProgressView()
			case .loaded:
				ActivityLogListView(completions: presenter.completions)
			case .empty:
				ContentUnavailableView(
					"No activity yet",
					systemImage: "checkmark.circle",
					description: Text("Complete a task in this room and it will appear here.")
				)
			case .error(let errorMessage):
				ContentUnavailableView(
					"Activity unavailable",
					systemImage: "exclamationmark.triangle",
					description: Text(errorMessage)
				)
				
			}
		}
		.navigationTitle("Activity")
		.toolbarTitleDisplayMode(.inline)
		.scrollEdgeEffectStyle(.soft, for: .top)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Close", action: presenter.onCloseButtonTapped)
			}
		}
		.onAppear {
			presenter.onAppear()
		}
	}
}

struct ActivityLogListView: View {
	let completions: [CompletedTask]

	var body: some View {
		List(completions) { completion in
			VStack(alignment: .leading) {
				Text(completion.taskName ?? "No task name")
					.font(FKTypography.bodyBold)
				Text(completion.completedAt.formatted())
					.font(FKTypography.footnoteEmphasis)
					.foregroundStyle(.secondary)
			}
		}
	}
}

// MARK: - ActivityLogByTaskView

private struct ActivityLogByTaskView: View {
	// MARK: - Properties
	
	let room: Room
	let tasks: [RoomTask]
	let completions: [CompletedTask]
	
	private var records: [ActivityLogRecord] {
		completions.map { completion in
			ActivityLogRecord(
				id: completion.id,
				taskName: completion.taskName
				?? tasks.first(where: { $0.id == completion.taskId })?.name
				?? "Completed task",
				completedAt: completion.completedAt,
				duration: completion.measuredDuration
			)
		}
		.sorted { $0.completedAt > $1.completedAt }
	}
	
	private var groupedRecords: [(name: String, records: [ActivityLogRecord])] {
		Dictionary(grouping: records, by: \.taskName)
			.map { (name: $0.key, records: $0.value) }
			.sorted { $0.records.count > $1.records.count }
	}
	
	private var totalMinutes: Int {
		records.compactMap { $0.duration }.reduce(0, +)
	}
	
	private var uniqueDays: Int {
		Set(records.map { Calendar.current.startOfDay(for: $0.completedAt) }).count
	}
	
	// MARK: - Body
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				roomHeader
				summaryStrip
				
				if groupedRecords.isEmpty {
					emptyMessage
				} else {
					ForEach(groupedRecords, id: \.name) { group in
						taskCard(group)
					}
				}
			}
			.padding(20)
		}
		.background(Color(uiColor: .systemGroupedBackground))
	}
	
	// MARK: - Views
	
	private var roomHeader: some View {
		VStack(alignment: .leading, spacing: 8) {
			Label(room.name, systemImage: room.kind.symbolName)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(.secondary)
			
			Text("Activity by task")
				.font(.title2.weight(.bold))
			
			Text("See how often each task gets done in this room.")
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
	}
	
	private var summaryStrip: some View {
		HStack(spacing: 12) {
			summaryMetric(value: records.count.formatted(), title: "completed", color: .blue)
			summaryMetric(value: totalMinutes.formatted(), title: "minutes", color: .orange)
			summaryMetric(value: uniqueDays.formatted(), title: "active days", color: .green)
		}
	}
	
	private func summaryMetric(value: String, title: String, color: Color) -> some View {
		VStack(alignment: .leading, spacing: 2) {
			Text(value)
				.font(.title3.weight(.bold))
				.foregroundStyle(color)
			
			Text(title)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	private func taskCard(
		_ group: (name: String, records: [ActivityLogRecord])
	) -> some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack {
				Text(group.name)
					.font(.headline)
				
				Spacer()
				
				Text(group.records.count.formatted())
					.font(.subheadline.weight(.bold))
					.foregroundStyle(.blue)
					.padding(.horizontal, 10)
					.padding(.vertical, 5)
					.background(.blue.opacity(0.1), in: Capsule())
			}
			
			ForEach(group.records) { record in
				recordRow(record)
				
				if record.id != group.records.last?.id {
					Divider()
				}
			}
		}
		.padding(20)
		.background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
	}
	
	private func recordRow(_ record: ActivityLogRecord) -> some View {
		HStack(spacing: 12) {
			Image(systemName: "checkmark.circle.fill")
				.foregroundStyle(.green)
			
			VStack(alignment: .leading, spacing: 3) {
				Text(record.completedAt.formatted(
					.dateTime
						.weekday(.abbreviated)
						.month(.abbreviated)
						.day()
						.hour()
						.minute()
				))
				.font(.subheadline)
				.foregroundStyle(.secondary)
			}
			
			Spacer()
			
			if let duration = record.duration {
				Text("\(duration)m")
					.font(.caption.weight(.semibold))
					.foregroundStyle(.secondary)
			}
		}
		.accessibilityElement(children: .combine)
	}
	
	private var emptyMessage: some View {
		ContentUnavailableView(
			"No completions yet",
			systemImage: "checkmark.circle",
			description: Text("Complete a task in this room and it will appear here.")
		)
		.frame(maxWidth: .infinity)
		.padding(.vertical, 80)
	}
}

// MARK: - ActivityLogRecord

private struct ActivityLogRecord: Identifiable {
	let id: UUID
	let taskName: String
	let completedAt: Date
	let duration: Int?
}

// MARK: - Preview Data

private enum ActivityLogPreviewData {
	static let room = Room(name: "Kitchen", kind: .kitchen)
	
	static let completions: [CompletedTask] = {
		let calendar = Calendar.current
		let names = [
			"Wipe counters",
			"Clean the stovetop",
			"Sweep the floor",
			"Empty the bin",
			"Mop the floor",
			"Polish the sink"
		]
		
		return (0..<14).map { index in
			CompletedTask(
				taskId: UUID(),
				roomId: room.id,
				roomName: room.name,
				taskName: names[index % names.count],
				completedAt: calendar.date(
					byAdding: .day,
					value: -(index * 2 + index / 4),
					to: .now
				) ?? .now,
				measuredDuration: [8, 12, 18, 6, 24, 10][index % 6]
			)
		}
	}()
}

// MARK: - Preview

#Preview("Loaded") {
	let container = DevPreview.shared.container
	container.register(CompletedTaskRepository.self, service: MockCompletedTaskRepository())
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)
	let room = Room.mock

	return RouterView { router in
		builder.activityLogView(
			router: router,
			room: room
		)
	}
}

#Preview("Empty state") {
	let container = DevPreview.shared.container
	container.register(CompletedTaskRepository.self, service: MockCompletedTaskRepository(items: []))
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)
	let room = Room.mock

	return RouterView { router in
		builder.activityLogView(
			router: router,
			room: room
		)
	}
}
