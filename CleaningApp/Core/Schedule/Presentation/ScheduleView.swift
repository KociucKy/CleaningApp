import SwiftUI
import FulhamKit

// MARK: - ScheduleView

@MainActor
struct ScheduleView: View {
	// MARK: - Properties
	
	@State private var presenter: SchedulePresenter
	@State private var selectedDay: Weekday
	@State private var completedTaskIDs: Set<UUID> = []
	
	// MARK: - Init
	
	init(presenter: SchedulePresenter) {
		_presenter = State(initialValue: presenter)
		_selectedDay = State(initialValue: .monday)
	}
	
	// MARK: - Body
	
	var body: some View {
		TabView(selection: $selectedDay) {
			ForEach(Weekday.allCases) { day in
				ZStack {
					Color.blue.ignoresSafeArea()
					Text(day.name)
				}
			}
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.navigationTitle("schedule.nav_title")
		.navigationSubtitle("schedule.nav_subtitle")
		.toolbarTitleDisplayMode(.inlineLarge)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					ForEach(Weekday.allCases) { weekday in
						Button {
							selectedDay = weekday
						} label: {
							let isSelected = selectedDay == weekday
							return HStack {
								Image(systemName: isSelected ? "checkmark" : "")
								Text(weekday.name)
							}
						}
					}
				} label: {
					Text(selectedDay.name)
				}

			}
		}
	}
	
	private var bodyContent: some View {
		TabView(selection: $selectedDay) {
			ForEach(Weekday.allCases) { day in
					List {
						Section {
							daySummary(for: day)
								.listRowBackground(Color.clear)
					}
					
					Section {
						let tasks = Self.weeklyTasks[day] ?? []
						if tasks.isEmpty {
							emptySchedule(for: day)
							} else {
								ForEach(tasks) { task in
									taskCard(task)
										.listRowBackground(Color.clear)
										.listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
										.listRowSeparator(.hidden)
								}
						}
					}
				}
					.tag(day)
					.listStyle(.plain)
					.scrollEdgeEffectStyle(.soft, for: .top)
			}
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.navigationTitle("schedule.nav_title")
		.navigationSubtitle("schedule.nav_subtitle")
		.toolbarTitleDisplayMode(.inlineLarge)
		.safeAreaBar(edge: .top, spacing: 0) {
			dayPicker
				.background(.bar)
		}
	}
	
	// MARK: - Header

	private var dayPicker: some View {
		ScrollView(.horizontal) {
			GlassEffectContainer(spacing: 8) {
				HStack(spacing: 8) {
					ForEach(Weekday.allCases) { day in
						Button {
							withAnimation(.smooth) {
								selectedDay = day
							}
						} label: {
							VStack(spacing: 2) {
								Text(day.shortName)
									.font(.caption.weight(.semibold))
							}
							.frame(width: 48, height: 40)
							.foregroundStyle(day == selectedDay ? .blue : .primary)
						}
						.buttonStyle(.plain)
						.subtleGlass(
							interactive: true,
							tint: day == selectedDay ? .blue.opacity(0.18) : nil,
							shape: .capsule
						)
						.accessibilityLabel(day.name)
						.accessibilityValue(day == selectedDay ? "Selected" : "")
					}
				}
				.padding(.horizontal, 20)
			}
		}
		.scrollIndicators(.hidden)
		.padding(.bottom, 8)
	}
	
	private func daySummary(for day: Weekday) -> some View {
		let tasks = Self.weeklyTasks[day] ?? []
		let completedCount = tasks.filter { completedTaskIDs.contains($0.id) }.count
		
		return VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .firstTextBaseline) {
				Text(day.name)
					.font(.title.weight(.bold))
				
				Spacer()
				
				Text("\(completedCount)/\(tasks.count)")
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(.blue)
			}
			
			Text(tasks.isEmpty ? "A clear day — enjoy the space." : "\(tasks.count) tasks • \(tasks.totalMinutes) min planned")
				.font(.subheadline)
				.foregroundStyle(.secondary)
			
			ProgressView(value: Double(completedCount), total: Double(max(tasks.count, 1)))
				.tint(.blue)
		}
		.padding(16)
		.subtleGlass(shape: .rect(cornerRadius: 20))
		.accessibilityElement(children: .combine)
	}
	
	private func emptySchedule(for day: Weekday) -> some View {
		ContentUnavailableView {
			Label("Nothing planned", systemImage: "sparkles")
		} description: {
			Text("\(day.name) is intentionally light.")
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 44)
	}
	
	private func taskCard(_ task: ScheduleTask) -> some View {
		let isCompleted = completedTaskIDs.contains(task.id)
		let detail = "\(task.room) • \(task.duration) min"
		let accessibilityLabel = "\(task.name), \(task.room), \(task.duration) minutes"
		let accessibilityHint = "Double-tap to mark as \(isCompleted ? "not completed" : "completed")"
		return Button {
			toggleCompletion(for: task)
		} label: {
			HStack(spacing: 14) {
				Image(systemName: isCompleted ? "checkmark.circle.fill" : task.symbolName)
					.font(.title3)
					.foregroundStyle(isCompleted ? .green : .blue)
					.frame(width: 28)
				
				VStack(alignment: .leading, spacing: 4) {
					Text(task.name)
						.font(.headline)
						.strikethrough(isCompleted, color: .secondary)
						.foregroundStyle(isCompleted ? .secondary : .primary)
					
					Text(detail)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				
				Spacer()
				
				Image(systemName: "circle")
					.font(.title3)
					.foregroundStyle(.tertiary)
					.opacity(isCompleted ? 0 : 1)
			}
			.padding()
		}
		.buttonStyle(.plain)
		.subtleGlass(tint: .blue.opacity(0.08), shape: .rect(cornerRadius: 16))
		.accessibilityLabel(accessibilityLabel)
		.accessibilityValue(isCompleted ? "Completed" : "Not completed")
		.accessibilityHint(accessibilityHint)
	}
	
	// MARK: - Actions
	
	private func toggleCompletion(for task: ScheduleTask) {
		if completedTaskIDs.contains(task.id) {
			completedTaskIDs.remove(task.id)
		} else {
			completedTaskIDs.insert(task.id)
		}
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
			switch self {
			case .monday: "Monday"
			case .tuesday: "Tuesday"
			case .wednesday: "Wednesday"
			case .thursday: "Thursday"
			case .friday: "Friday"
			case .saturday: "Saturday"
			case .sunday: "Sunday"
			}
		}
		
		var shortName: String {
			String(name.prefix(3)).uppercased()
		}
		
		var date: String {
			"\(14 + rawValue)"
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
		let tint: Color?
		
		init(
			name: String,
			room: String,
			duration: Int,
			symbolName: String,
			tint: Color? = nil
		) {
			id = UUID()
			self.name = name
			self.room = room
			self.duration = duration
			self.symbolName = symbolName
			self.tint = tint
		}
	}
}

private extension Array where Element == ScheduleView.ScheduleTask {
	var totalMinutes: Int {
		reduce(0) { $0 + $1.duration }
	}
}

// MARK: - ScheduleView.MockData

private extension ScheduleView {
	static let weeklyTasks: [Weekday: [ScheduleTask]] = [
		.monday: [
			ScheduleTask(name: "Wipe kitchen counters", room: "Kitchen", duration: 10, symbolName: "sparkles"),
			ScheduleTask(name: "Vacuum living room", room: "Living room", duration: 15, symbolName: "sofa"),
			ScheduleTask(name: "Make the bed", room: "Bedroom", duration: 5, symbolName: "bed.double")
		],
		.tuesday: [
			ScheduleTask(name: "Clean bathroom sink", room: "Bathroom", duration: 10, symbolName: "drop"),
			ScheduleTask(name: "Sort the mail", room: "Hallway", duration: 10, symbolName: "envelope"),
			ScheduleTask(name: "Water plants", room: "Living room", duration: 8, symbolName: "leaf")
		],
		.wednesday: [
			ScheduleTask(name: "Change towels", room: "Bathroom", duration: 8, symbolName: "hand.raised"),
			ScheduleTask(name: "Wipe desk", room: "Office", duration: 8, symbolName: "desktopcomputer"),
			ScheduleTask(name: "Start a laundry load", room: "Laundry", duration: 10, symbolName: "washer")
		],
		.thursday: [
			ScheduleTask(name: "Clean the stovetop", room: "Kitchen", duration: 12, symbolName: "fork.knife"),
			ScheduleTask(name: "Dust shelves", room: "Living room", duration: 12, symbolName: "books.vertical"),
			ScheduleTask(name: "Tidy bedside table", room: "Bedroom", duration: 5, symbolName: "lamp.table")
		],
		.friday: [
			ScheduleTask(name: "Empty bathroom bin", room: "Bathroom", duration: 5, symbolName: "trash"),
			ScheduleTask(name: "Sweep hallway", room: "Hallway", duration: 10, symbolName: "broom"),
			ScheduleTask(name: "Freshen the sofa", room: "Living room", duration: 10, symbolName: "sofa")
		],
		.saturday: [
			ScheduleTask(name: "Mop kitchen floor", room: "Kitchen", duration: 20, symbolName: "drop"),
			ScheduleTask(name: "Change bed sheets", room: "Bedroom", duration: 15, symbolName: "bed.double"),
			ScheduleTask(name: "Clean mirrors", room: "Bathroom", duration: 10, symbolName: "rectangle.on.rectangle")
		],
		.sunday: [
			ScheduleTask(name: "Plan the week", room: "Home", duration: 10, symbolName: "calendar"),
			ScheduleTask(name: "Reset entryway", room: "Hallway", duration: 10, symbolName: "door.left.hand.open"),
			ScheduleTask(name: "Take out recycling", room: "Kitchen", duration: 8, symbolName: "arrow.3.trianglepath")
		]
	]
}

// MARK: - Preview

private extension ScheduleView {
	static var preview: some View {
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
}

#Preview("Monday Focus") {
	ScheduleView.preview
}
