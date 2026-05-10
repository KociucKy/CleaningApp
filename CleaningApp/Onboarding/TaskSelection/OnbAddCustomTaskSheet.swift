import FulhamKit
import SwiftUI

// MARK: - OnbAddCustomTaskSheet

struct OnbAddCustomTaskSheet: View {
	// MARK: - Properties

	@Binding var isPresented: Bool
	let roomType: RoomType
	let onAdd: (RoomTask) -> Void

	@State private var taskName = ""
	@State private var selectedFrequency: Frequency = .timesPerWeek(1)

	// MARK: - Body

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("onb_custom_task.placeholder.task_name", text: $taskName)
						.autocorrectionDisabled()
				} header: {
					Text("onb_custom_task.label.task_name")
				}

				Section {
					Picker("onb_custom_task.label.frequency", selection: $selectedFrequency) {
						Text(Frequency.daily.displayName).tag(Frequency.daily)
						Text(Frequency.timesPerWeek(2).displayName).tag(Frequency.timesPerWeek(2))
						Text(Frequency.timesPerWeek(3).displayName).tag(Frequency.timesPerWeek(3))
						Text(Frequency.timesPerWeek(1).displayName).tag(Frequency.timesPerWeek(1))
						Text(Frequency.everyOtherWeek.displayName).tag(Frequency.everyOtherWeek)
						Text(Frequency.monthly.displayName).tag(Frequency.monthly)
					}
				} header: {
					Text("onb_custom_task.label.frequency")
				}
			}
			.navigationTitle("onb_custom_task.title")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("common.action.cancel") {
						isPresented = false
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("common.action.add") {
						let task = RoomTask(
							name: taskName,
							roomId: UUID(), // Placeholder - will be set during save
							frequency: selectedFrequency,
							estimatedDuration: .fifteenMinutes
						)
						FKHaptics.selection()
						onAdd(task)
						isPresented = false
					}
					.disabled(taskName.trimmingCharacters(in: .whitespaces).isEmpty)
				}
			}
		}
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var isPresented = true
	OnbAddCustomTaskSheet(
		isPresented: $isPresented,
		roomType: .kitchen,
		onAdd: { task in
			print("Added task: \(task.name)")
		}
	)
}
