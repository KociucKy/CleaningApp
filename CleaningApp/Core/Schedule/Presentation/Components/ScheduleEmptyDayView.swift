import SwiftUI

struct ScheduleEmptyDayView: View {
	var weekdayName: String

	var body: some View {
		ContentUnavailableView {
			Label("Nothing planned", systemImage: "sparkles")
		} description: {
			Text("\(weekdayName) is intentionally light.")
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 44)
	}
}

#Preview {
	ScheduleEmptyDayView(weekdayName: "Friday")
}
