import Charts
import SwiftUI

// MARK: - RoomsDetailsCompletionChartView

struct RoomsDetailsCompletionChartView: View {
	// MARK: - Properties

	enum Style {
		case bar
		case line

		var title: String {
			switch self {
			case .bar:
				"Bar chart prototype"
			case .line:
				"Line chart prototype"
			}
		}
	}

	let dataPoints: [CompletionChartDataPoint]
	let style: Style

	private var maximumCount: Int {
		max(dataPoints.map(\.completedCount).max() ?? 0, 1)
	}

	private var markGradient: LinearGradient {
		LinearGradient(
			colors: [.accentColor, .accentColor.opacity(0.55)],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	// MARK: - Body

	var body: some View {
		Section(style.title) {
			Chart(dataPoints) { dataPoint in
				switch style {
				case .bar:
					BarMark(
						x: .value("Day", dataPoint.date, unit: .day),
						y: .value("Completed", dataPoint.completedCount)
					)
					.foregroundStyle(markGradient)
				case .line:
					LineMark(
						x: .value("Day", dataPoint.date, unit: .day),
						y: .value("Completed", dataPoint.completedCount)
					)
					.interpolationMethod(.catmullRom)
					.foregroundStyle(markGradient)
					PointMark(
						x: .value("Day", dataPoint.date, unit: .day),
						y: .value("Completed", dataPoint.completedCount)
					)
					.foregroundStyle(markGradient)
				}
			}
			.chartYScale(domain: 0 ... maximumCount)
			.chartXAxis {
				AxisMarks(values: .stride(by: .day)) { _ in
					AxisGridLine()
					AxisTick()
					AxisValueLabel(format: .dateTime.weekday(.abbreviated))
				}
			}
			.chartYAxis {
				AxisMarks(position: .leading, values: .stride(by: 1))
			}
			.frame(height: 180)
			.accessibilityLabel(style.title)
			.accessibilityValue(accessibilityValue)
		}
	}

	// MARK: - Accessibility

	private var accessibilityValue: String {
		let total = dataPoints.reduce(0) { $0 + $1.completedCount }
		return "\(total) completions in the last 7 days"
	}
}
