import SwiftUI

// MARK: - RoomsDetailsTaskCompletionView
struct RoomsDetailsTaskCompletionView: View {
	@State private var presenter: RoomsDetailsTaskCompletionPresenter

	init(presenter: RoomsDetailsTaskCompletionPresenter) {
		self._presenter = State(wrappedValue: presenter)
	}

	var body: some View {
		Text("Task Completion")
	}
}

//struct RoomsDetailsTaskCompletionView: View {
//    // MARK: - Presentation
//
//    enum Presentation: CaseIterable {
//        case hero
//        case card
//        case timeline
//        case wheel
//        case presets
//        case confirmation
//        case calendar
//        case duration
//        case minimal
//        case encouragement
//    }
//
//    // MARK: - Properties
//
//    let taskName: String
//    let estimatedDuration: Int
//    let presentation: Presentation
//
//    @State private var completedAt: Date
//
//    private var formattedTime: String {
//        completedAt.formatted(date: .omitted, time: .shortened)
//    }
//
//    private var formattedDate: String {
//        completedAt.formatted(date: .abbreviated, time: .omitted)
//    }
//
//    // MARK: - Init
//
//    init(
//        taskName: String = "Wipe the kitchen counters",
//        estimatedDuration: Int = 10,
//        presentation: Presentation = .hero,
//        completedAt: Date = Date()
//    ) {
//        self.taskName = taskName
//        self.estimatedDuration = estimatedDuration
//        self.presentation = presentation
//        _completedAt = State(initialValue: completedAt)
//    }
//
//    // MARK: - Body
//
//    var body: some View {
//        Group {
//            switch presentation {
//            case .hero:
//                heroView
//            case .card:
//                cardView
//            case .timeline:
//                timelineView
//            case .wheel:
//                wheelView
//            case .presets:
//                presetsView
//            case .confirmation:
//                confirmationView
//            case .calendar:
//                calendarView
//            case .duration:
//                durationView
//            case .minimal:
//                minimalView
//            case .encouragement:
//                encouragementView
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(uiColor: .systemGroupedBackground))
//    }
//
//    // MARK: - Shared Views
//
//    private var taskHeader: some View {
//        VStack(spacing: 8) {
//            Image(systemName: "checkmark.circle.fill")
//                .font(.system(size: 48))
//                .symbolRenderingMode(.hierarchical)
//                .foregroundStyle(.green)
//
//            Text("Task completed")
//                .font(.title2.weight(.bold))
//
//            Text(taskName)
//                .font(.headline)
//                .multilineTextAlignment(.center)
//
//            Text("Estimated (estimatedDuration) minutes")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//        }
//    }
//
//    private var dateAndTimePicker: some View {
//        DatePicker(
//            "Completed at",
//            selection: $completedAt,
//            displayedComponents: [.date, .hourAndMinute]
//        )
//        .datePickerStyle(.compact)
//    }
//
//    private var quickTimeButtons: some View {
//        HStack(spacing: 8) {
//            quickTimeButton(title: "Now", offset: 0)
//            quickTimeButton(title: "15 min ago", offset: -15 * 60)
//            quickTimeButton(title: "1 hour ago", offset: -60 * 60)
//        }
//    }
//
//    private func quickTimeButton(title: String, offset: TimeInterval) -> some View {
//        Button(title) {
//            completedAt = Date().addingTimeInterval(offset)
//        }
//        .buttonStyle(.bordered)
//        .controlSize(.small)
//    }
//
//    private var completionAction: some View {
//        Button("Mark as completed") {}
//            .buttonStyle(.borderedProminent)
//            .controlSize(.large)
//            .frame(maxWidth: .infinity)
//            .accessibilityHint("Completion is not wired up yet")
//    }
//
//    // MARK: - Prototype Views
//
//    private var heroView: some View {
//        VStack(spacing: 24) {
//            Spacer()
//            taskHeader
//            dateAndTimePicker
//                .padding()
//                .background(.background, in: RoundedRectangle(cornerRadius: 20))
//            quickTimeButtons
//            completionAction
//            Spacer()
//        }
//    }
//
//    private var cardView: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Label("Finish a task", systemImage: "checkmark.circle")
//                .font(.title2.weight(.bold))
//
//            VStack(alignment: .leading, spacing: 6) {
//                Text(taskName)
//                    .font(.headline)
//                Text("Choose when you finished it.")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//            }
//
//            dateAndTimePicker
//                .padding()
//                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
//
//            quickTimeButtons
//            Spacer()
//            completionAction
//        }
//        .padding()
//        .background(.background, in: RoundedRectangle(cornerRadius: 24))
//    }
//
//    private var timelineView: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Text("When did this happen?")
//                .font(.largeTitle.weight(.bold))
//                .padding(.bottom, 8)
//
//            Text(taskName)
//                .font(.headline)
//                .foregroundStyle(.secondary)
//                .padding(.bottom, 28)
//
//            timelineRow(icon: "play.circle.fill", title: "Started", detail: "About (estimatedDuration) minutes before completion")
//            timelineRow(icon: "checkmark.circle.fill", title: "Finished", detail: "(formattedDate) at (formattedTime)")
//                .foregroundStyle(.green)
//
//            Spacer()
//            dateAndTimePicker
//            quickTimeButtons
//                .padding(.vertical)
//            completionAction
//        }
//    }
//
//    private func timelineRow(icon: String, title: String, detail: String) -> some View {
//        HStack(alignment: .top, spacing: 14) {
//            Image(systemName: icon)
//                .font(.title2)
//                .frame(width: 28)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.headline)
//                Text(detail)
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//            }
//            .padding(.bottom, 28)
//        }
//    }
//
//    private var wheelView: some View {
//        VStack(spacing: 20) {
//            taskHeader
//            Text(formattedTime)
//                .font(.system(size: 52, weight: .bold, design: .rounded))
//                .monospacedDigit()
//
//            DatePicker("Completion time", selection: $completedAt, displayedComponents: .hourAndMinute)
//                .datePickerStyle(.wheel)
//                .labelsHidden()
//                .frame(height: 170)
//
//            Button("Use today, (formattedDate)") {
//                completedAt = Date()
//            }
//            .buttonStyle(.bordered)
//
//            Spacer()
//            completionAction
//        }
//    }
//
//    private var presetsView: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Log completion")
//                .font(.largeTitle.weight(.bold))
//
//            Text(taskName)
//                .font(.headline)
//
//            Text("Pick a shortcut or set an exact time.")
//                .foregroundStyle(.secondary)
//
//            VStack(spacing: 10) {
//                presetRow(title: "Just now", subtitle: "A moment ago", offset: 0, icon: "bolt.fill")
//                presetRow(title: "15 minutes ago", subtitle: "A quick cleaning session", offset: -15 * 60, icon: "clock")
//                presetRow(title: "1 hour ago", subtitle: "Earlier today", offset: -60 * 60, icon: "clock.arrow.circlepath")
//            }
//
//            dateAndTimePicker
//            Spacer()
//            completionAction
//        }
//    }
//
//    private func presetRow(
//        title: String,
//        subtitle: String,
//        offset: TimeInterval,
//        icon: String
//    ) -> some View {
//        Button {
//            completedAt = Date().addingTimeInterval(offset)
//        } label: {
//            HStack(spacing: 14) {
//                Image(systemName: icon)
//                    .frame(width: 24)
//                VStack(alignment: .leading) {
//                    Text(title)
//                        .font(.headline)
//                    Text(subtitle)
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                }
//                Spacer()
//                if abs(completedAt.timeIntervalSinceNow - offset) < 5 {
//                    Image(systemName: "checkmark")
//                        .font(.headline.weight(.bold))
//                }
//            }
//            .padding()
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//        .background(.background, in: RoundedRectangle(cornerRadius: 14))
//    }
//
//    private var confirmationView: some View {
//        VStack(spacing: 22) {
//            Spacer()
//            Image(systemName: "checkmark.seal.fill")
//                .font(.system(size: 76))
//                .foregroundStyle(.tint)
//
//            Text("Ready to log?")
//                .font(.largeTitle.weight(.bold))
//
//            Text(taskName)
//                .font(.headline)
//                .multilineTextAlignment(.center)
//
//            VStack(spacing: 4) {
//                Text("Completed")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                Text("(formattedDate) at (formattedTime)")
//                    .font(.title3.weight(.semibold))
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(.background, in: RoundedRectangle(cornerRadius: 16))
//
//            dateAndTimePicker
//            Spacer()
//            completionAction
//        }
//    }
//
//    private var calendarView: some View {
//        VStack(alignment: .leading, spacing: 18) {
//            Text("When did you clean?")
//                .font(.largeTitle.weight(.bold))
//
//            Label(taskName, systemImage: "sparkles")
//                .font(.headline)
//
//            DatePicker(
//                "Completion date",
//                selection: $completedAt,
//                displayedComponents: .date
//            )
//            .datePickerStyle(.graphical)
//            .padding(.vertical, -8)
//
//            DatePicker(
//                "Time",
//                selection: $completedAt,
//                displayedComponents: .hourAndMinute
//            )
//            .datePickerStyle(.compact)
//
//            Spacer()
//            completionAction
//        }
//    }
//
//    private var durationView: some View {
//        VStack(spacing: 22) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Nice work")
//                        .font(.title2.weight(.bold))
//                    Text(taskName)
//                        .font(.headline)
//                }
//                Spacer()
//                Image(systemName: "sparkles")
//                    .font(.title)
//                    .foregroundStyle(.orange)
//            }
//
//            VStack(spacing: 8) {
//                Text("Completed at")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                Text(formattedTime)
//                    .font(.system(size: 44, weight: .bold, design: .rounded))
//                    .monospacedDigit()
//                Text(formattedDate)
//                    .foregroundStyle(.secondary)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 24)
//            .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
//
//            dateAndTimePicker
//
//            Text("A (estimatedDuration)-minute task logged in seconds.")
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//
//            Spacer()
//            completionAction
//        }
//    }
//
//    private var minimalView: some View {
//        VStack(spacing: 18) {
//            Spacer()
//            Text(taskName)
//                .font(.title2.weight(.semibold))
//                .multilineTextAlignment(.center)
//
//            Text(formattedTime)
//                .font(.system(size: 64, weight: .bold, design: .rounded))
//                .monospacedDigit()
//
//            Text(formattedDate)
//                .foregroundStyle(.secondary)
//
//            DatePicker("Completion time", selection: $completedAt, displayedComponents: [.date, .hourAndMinute])
//                .labelsHidden()
//                .datePickerStyle(.compact)
//
//            quickTimeButtons
//            Spacer()
//            completionAction
//        }
//    }
//
//    private var encouragementView: some View {
//        VStack(spacing: 22) {
//            Spacer()
//            Text("One less thing to think about")
//                .font(.largeTitle.weight(.bold))
//                .multilineTextAlignment(.center)
//
//            Image(systemName: "hands.clap.fill")
//                .font(.system(size: 64))
//                .foregroundStyle(.purple)
//
//            Text(taskName)
//                .font(.headline)
//
//            Text("When did you finish this (estimatedDuration)-minute task?")
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//
//            dateAndTimePicker
//                .padding()
//                .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
//
//            quickTimeButtons
//            Spacer()
//            completionAction
//        }
//    }
//}
