import SwiftUI

// MARK: - TaskDurationStepperView

@MainActor
struct TaskDurationStepperView: View {
	// MARK: - Properties

	@Binding var duration: TaskDuration

	// MARK: - Body

	var body: some View {
		Stepper(value: durationBinding, in: 5 ... 60, step: 5) {
			HStack {
				Text("Estimated time")
				Spacer()
				Text("\(duration.rawValue) min")
					.foregroundStyle(.secondary)
					.monospacedDigit()
			}
		}
		.accessibilityValue(Text("\(duration.rawValue) minutes"))
	}

	// MARK: - Private

	private var durationBinding: Binding<Int> {
		Binding(
			get: { duration.rawValue },
			set: { newValue in
				guard let newDuration = TaskDuration(rawValue: newValue) else {
					return
				}
				duration = newDuration
			}
		)
	}
}
