import SwiftUI

struct ScheduleEmptyDayView: View {
	var weekdayName: String

	var body: some View {
		ContentUnavailableView {
				Label(
					String(localized: .init(
						"schedule.empty.title",
						defaultValue: "Nothing planned"
					)),
					systemImage: "sparkles"
				)
			} description: {
				Text(String(localized: .init(
					"schedule.empty.description",
					defaultValue: "\(weekdayName) is intentionally light."
				)))
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 44)
	}
}

#Preview {
	ScheduleEmptyDayView(weekdayName: "Friday")
}
