import SwiftUI

// MARK: - ScheduleTaskRescheduleView

@MainActor
struct ScheduleTaskRescheduleView: View {
    // MARK: - Properties

    let task: ScheduleTaskRow
    let onReschedule: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var scheduledDate: Date

    // MARK: - Init

    init(
        task: ScheduleTaskRow,
        onReschedule: @escaping (Date) -> Void
    ) {
        self.task = task
        self.onReschedule = onReschedule
        _scheduledDate = State(initialValue: Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: task.scheduledDate
        ) ?? Date.now)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    String(localized: .init(
                        "schedule.reschedule.date",
                        defaultValue: "New date"
                    )),
                    selection: $scheduledDate,
                    in: Date.now...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
            .navigationTitle(String(localized: .init(
                "schedule.reschedule.title",
                defaultValue: "Reschedule \(task.name)"
            )))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.action.cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.action.save") {
                        onReschedule(scheduledDate)
                        dismiss()
                    }
                    .disabled(Calendar.current.isDate(
                        scheduledDate,
                        inSameDayAs: task.scheduledDate
                    ))
                }
            }
        }
        .presentationSizing(.fitted)
    }
}
