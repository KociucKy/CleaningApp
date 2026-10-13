import SwiftUI

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
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.24),
                    Color.blue.opacity(0.06),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                dayPicker

                TabView(selection: $selectedDay) {
                    ForEach(Weekday.allCases) { day in
                        daySchedule(for: day)
                            .tag(day)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .navigationTitle("Schedule")
        .navigationSubtitle("Your week at a glance")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("A focused Monday")
                .font(.title2.weight(.bold))

            Text("Three small wins before lunch.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

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
                                Text(day.date)
                                    .font(.headline)
                            }
                            .frame(width: 48, height: 54)
                            .foregroundStyle(day == selectedDay ? .white : .primary)
                            .background {
                                if day == selectedDay {
                                    Capsule()
                                        .fill(Color.blue.gradient)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .scheduleGlass(
                            interactive: true,
                            shape: .capsule,
                            tint: day == selectedDay ? .blue : nil
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

    // MARK: - Day Schedule

    private func daySchedule(for day: Weekday) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                daySummary(for: day)

                let tasks = Self.weeklyTasks[day] ?? []
                if tasks.isEmpty {
                    emptySchedule(for: day)
                } else {
                    ForEach(tasks) { task in
                        taskCard(task)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
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
        .padding(18)
        .scheduleGlass(shape: .rect(cornerRadius: 24), tint: .blue.opacity(0.3))
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
        .scheduleGlass(shape: .rect(cornerRadius: 24), tint: .blue.opacity(0.2))
    }

    private func taskCard(_ task: ScheduleTask) -> some View {
        let isCompleted = completedTaskIDs.contains(task.id)
        let detail = "\(task.room) • \(task.duration) min"
        let accessibilityLabel = "\(task.name), \(task.room), \(task.duration) minutes"
        let accessibilityHint = "Double-tap to mark as \(isCompleted ? "not completed" : "completed")"
        let cardTint = task.tint ?? .blue.opacity(0.18)

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
            .padding(16)
        }
        .buttonStyle(.plain)
        .scheduleGlass(interactive: true, shape: .rect(cornerRadius: 20), tint: cardTint)
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

// MARK: - Liquid Glass

private extension View {
    @ViewBuilder
    func scheduleGlass<S: Shape>(
        interactive: Bool = false,
        shape: S,
        tint: Color? = nil
    ) -> some View {
        if #available(iOS 26, *) {
            let glass = tint.map { Glass.regular.tint($0) } ?? .regular

            if interactive {
                self.glassEffect(glass.interactive(), in: shape)
            } else {
                self.glassEffect(glass, in: shape)
            }
        } else {
            self.background(.ultraThinMaterial, in: shape)
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
