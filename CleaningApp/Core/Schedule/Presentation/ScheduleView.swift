import SwiftUI
import FulhamKit

// MARK: - ScheduleView

@MainActor
struct ScheduleView: View {
	// MARK: - Properties
	
	private enum Constants {
		static let topContentMargin: CGFloat = 48
	}

	@State private var presenter: SchedulePresenter
	@State private var selectedDay: Weekday?
	
	// MARK: - Init
	
	init(presenter: SchedulePresenter) {
		_presenter = State(initialValue: presenter)
			_selectedDay = State(initialValue: .monday)
	}
	
	// MARK: - Body
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 0) {
				ForEach(Weekday.allCases) { day in
					List {
						Section {
							daySummary(for: day)
								.removeListRowFormatting()
						}
						Section {
							let tasks = presenter.tasks(for: day)
							if tasks.isNotEmpty {
								ForEach(tasks) { task in
									taskCard(task)
								}
							} else {
								ScheduleEmptyDayView(weekdayName: day.name)
							}
						}
					}
					.containerRelativeFrame(.horizontal)
				}
			}
			.scrollTargetLayout()
		}
		.scrollTargetBehavior(.paging)
		.scrollPosition(id: $selectedDay, anchor: .center)
		.scrollEdgeEffectStyle(.soft, for: .top)
		.background(FKColor.Background.primary)
		.onAppear {
			let today = Date()
			presenter.ensureSchedule(today: today)
			selectedDay = presenter.currentWeekday
		}
		.navigationTitle("schedule.nav_title")
		.navigationSubtitle("schedule.nav_subtitle")
		.toolbarTitleDisplayMode(.inlineLarge)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					presenter.refresh()
				} label: {
					Image(systemName: "arrow.clockwise")
				}
				.accessibilityLabel("Refresh schedule")
			}
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					ForEach(Weekday.allCases) { weekday in
						Button {
							withAnimation(.smooth) {
								selectedDay = weekday
							}
						} label: {
							let isSelected = selectedDay == weekday
							return HStack {
								Image(systemName: isSelected ? "checkmark" : "")
								Text(weekday.name)
							}
						}
					}
					} label: {
						Text(selectedDay?.name ?? "")
				}
			}
		}
	}
	
	private func daySummary(for day: Weekday) -> some View {
		let tasks = presenter.tasks(for: day)
		let completedCount = tasks.filter { $0.status == .completed }.count
		
		return VStack(alignment: .leading, spacing: FKSpacing.default) {
			HStack(alignment: .firstTextBaseline) {
				Text(day.name)
					.font(FKTypography.statValue)
				Spacer()
				Text("\(completedCount)/\(tasks.count)")
					.font(FKTypography.secondaryLabel)
					.fontWeight(.semibold)
					.foregroundStyle(.accent)
			}
			
			Text(tasks.isEmpty ? "A clear day — enjoy the space." : "\(tasks.count) tasks • \(tasks.totalMinutes) min planned")
				.font(FKTypography.secondaryLabel)
				.foregroundStyle(.secondary)
			
			ProgressView(value: Double(completedCount), total: Double(max(tasks.count, 1)))
				.tint(.accent)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(FKSpacing.large)
		.background(FKColor.Background.canvas)
		.accessibilityElement(children: .combine)
	}
	
	@ViewBuilder
	private func taskCard(_ task: ScheduleTask) -> some View {
		if task.status == .planned {
			Button {
				presenter.complete(task)
			} label: {
				taskCardContent(task)
			}
			.buttonStyle(.fkFade)
			.contextMenu {
				Button("Skip task", systemImage: "arrowshape.turn.up.right") {
					presenter.skip(task)
				}
			}
		} else if task.status == .skipped {
			taskCardContent(task)
				.contextMenu {
					Button("Undo Skip", systemImage: "arrow.uturn.backward") {
						presenter.undoSkip(task)
					}
				}
		} else if task.status == .completed {
			taskCardContent(task)
				.contextMenu {
					Button("schedule.action.uncomplete", systemImage: "arrow.uturn.backward") {
						presenter.uncomplete(task)
					}
				}
		} else {
			taskCardContent(task)
		}
	}

	private func taskCardContent(_ task: ScheduleTask) -> some View {
		let isCompleted = task.status == .completed
		let detail = "\(task.room) • \(task.duration) min"
		let accessibilityLabel = "\(task.name), \(task.room), \(task.duration) minutes"
		return HStack(spacing: FKSpacing.large) {
				Image(systemName: isCompleted ? "checkmark.circle.fill" : task.symbolName)
					.font(FKTypography.sectionHeader)
					.foregroundStyle(.accent.gradient)
					.padding(FKSpacing.default)
					.background(.accent.opacity(0.2), in: .circle)
					.frame(width: 28)
				
				VStack(alignment: .leading, spacing: FKSpacing.extraSmall) {
					Text(task.name)
						.font(FKTypography.ctaLabel)
						.strikethrough(isCompleted, color: .secondary)
						.foregroundStyle(isCompleted ? .secondary : .primary)
					
					Text(detail)
						.font(FKTypography.secondaryLabel)
						.foregroundStyle(.secondary)

					if task.status != .planned {
						Text(task.statusDescription)
							.font(FKTypography.secondaryLabel)
							.foregroundStyle(task.status == .postponed ? .orange : .secondary)
					}
				}
				
				Spacer()

				if task.status == .skipped {
					Button("Undo Skip") {
						presenter.undoSkip(task)
					}
					.buttonStyle(.borderless)
				} else {
					Image(systemName: "circle")
						.font(FKTypography.sectionHeader)
						.foregroundStyle(.tertiary)
						.opacity(isCompleted ? 0 : 1)
				}
		}
		.frame(maxWidth: .infinity)
		.accessibilityLabel(accessibilityLabel)
		.accessibilityValue(task.statusDescription)
	}
}

// MARK: - Subtle Glass

private extension View {
    @ViewBuilder
    func subtleGlass<S: Shape>(
        interactive: Bool = false,
        tint: Color? = nil,
        shape: S
    ) -> some View {
        let glass = tint.map { Glass.regular.tint($0) } ?? .regular

        if interactive {
            self.glassEffect(glass.interactive(), in: shape)
        } else {
            self.glassEffect(glass, in: shape)
        }
    }
}

// MARK: - ScheduleView.Weekday

extension ScheduleView {
		enum Weekday: Int, CaseIterable, Identifiable {
		case monday
		case tuesday
		case wednesday
		case thursday
		case friday
		case saturday
		case sunday
		
		var id: Self { self }
		
		var name: String {
			localizedName(in: .current)
		}
		
		var shortName: String {
			localizedShortName(in: .current)
		}
		
		var date: String {
			"\(14 + rawValue)"
		}

		init(date: Date, calendar: Calendar) {
			switch calendar.component(.weekday, from: date) {
			case 2: self = .monday
			case 3: self = .tuesday
			case 4: self = .wednesday
			case 5: self = .thursday
			case 6: self = .friday
			case 7: self = .saturday
			default: self = .sunday
			}
		}

		func localizedName(in calendar: Calendar) -> String {
			calendar.weekdaySymbols[calendarWeekday - 1]
				.capitalized(with: calendar.locale ?? .current)
		}

		func localizedShortName(in calendar: Calendar) -> String {
			calendar.shortWeekdaySymbols[calendarWeekday - 1]
				.capitalized(with: calendar.locale ?? .current)
		}

		private var calendarWeekday: Int {
			switch self {
			case .monday: 2
			case .tuesday: 3
			case .wednesday: 4
			case .thursday: 5
			case .friday: 6
			case .saturday: 7
			case .sunday: 1
			}
		}
	}
}

// MARK: - ScheduleView.ScheduleTask

extension ScheduleView {
	struct ScheduleTask: Identifiable {
		let id: UUID
		let name: String
		let room: String
		let duration: Int
		let symbolName: String
		let status: ScheduledTaskStatus

		var statusDescription: String {
			switch status {
			case .planned: "Planned"
			case .completed: "Completed"
			case .skipped: "Skipped"
			case .postponed: "Backlog"
			case .cancelled: "Cancelled"
			}
		}
		
		init(
			id: UUID,
			name: String,
			room: String,
			duration: Int,
			symbolName: String,
			status: ScheduledTaskStatus
		) {
			self.id = id
			self.name = name
			self.room = room
			self.duration = duration
			self.symbolName = symbolName
			self.status = status
		}
	}
}

private extension Array where Element == ScheduleView.ScheduleTask {
	var totalMinutes: Int {
		reduce(0) { $0 + $1.duration }
	}
}


// MARK: - Preview

#Preview("Monday Focus") {
	let container = DevPreview.shared.container
	let interactor = CoreInteractor(container: container)
	let builder = CoreBuilder(interactor: interactor)
	
	return RouterView { router in
		ScheduleView(
			presenter: SchedulePresenter(
				interactor: interactor,
				router: CoreRouter(router: router, builder: builder)
			)
		)
	}
}

