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
							ScheduleDaySummaryView(summary: presenter.summary(for: day))
								.removeListRowFormatting()
						}
						Section {
							taskSection(for: day)
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
	
	@ViewBuilder
	private func taskSection(for day: Weekday) -> some View {
		let tasks = presenter.tasks(for: day)

		if tasks.isNotEmpty {
			ForEach(tasks) { task in
				taskCard(task)
			}
		} else {
			ScheduleEmptyDayView(weekdayName: day.name)
		}
	}

	@ViewBuilder
	private func taskCard(_ task: ScheduleTaskRow) -> some View {
		switch task.status {
		case .planned:
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
		case .skipped:
			taskCardContent(task)
				.contextMenu {
					Button("Undo Skip", systemImage: "arrow.uturn.backward") {
						presenter.undoSkip(task)
					}
				}
		case .completed:
			taskCardContent(task)
				.contextMenu {
					Button("schedule.action.uncomplete", systemImage: "arrow.uturn.backward") {
						presenter.uncomplete(task)
					}
				}
		case .postponed, .cancelled:
			taskCardContent(task)
		}
	}

	private func taskCardContent(_ task: ScheduleTaskRow) -> some View {
		ScheduleTaskCardView(
			task: task,
			onUndoSkipButtonTapped: { task in
				presenter.undoSkip(task)
			}
		)
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


// MARK: - Preview

#Preview {
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
