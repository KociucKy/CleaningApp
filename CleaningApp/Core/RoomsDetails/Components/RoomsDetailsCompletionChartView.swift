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

	@State private var selectedDate: Date?

	private var maximumCount: Int {
		max(dataPoints.map(\.completedCount).max() ?? 0, 1)
	}

	private var completionCounts: [Int] {
		dataPoints.map(\.completedCount)
	}

	private var markGradient: LinearGradient {
		LinearGradient(
			colors: [.accentColor, .accentColor.opacity(0.55)],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	private var selectedDataPoint: CompletionChartDataPoint? {
		guard let selectedDate else {
			return nil
		}
		return dataPoints.first {
			Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
		}
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
			.chartYAxisLabel(position: .leading) {
				Text("Finished tasks")
					.rotationEffect(.degrees(180))
			}
			.chartXSelection(value: $selectedDate)
			.animation(.easeInOut(duration: 0.35), value: completionCounts)
			.chartOverlay { proxy in
				GeometryReader { geometry in
					if let selectedDataPoint,
						let xPosition = proxy.position(forX: selectedDataPoint.date) {
						let overlayWidth = min(max(geometry.size.width - 24, 0), 220)
						let centeredX = min(
							max(xPosition, overlayWidth / 2 + 12),
							geometry.size.width - overlayWidth / 2 - 12
						)
						selectedDayView(for: selectedDataPoint)
							.frame(width: overlayWidth)
							.position(x: centeredX, y: 70)
					}
				}
			}
			.frame(height: 180)
			.accessibilityLabel(style.title)
			.accessibilityValue(accessibilityValue)
		}
	}

	// MARK: - Views

	private func selectedDayView(for dataPoint: CompletionChartDataPoint) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(dataPoint.date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
				.font(.headline)

			if dataPoint.taskCounts.isEmpty {
				Text("No tasks finished")
					.foregroundStyle(.secondary)
			} else {
				ForEach(dataPoint.taskCounts.keys.sorted(), id: \.self) { taskName in
					let count = dataPoint.taskCounts[taskName] ?? 0
					HStack(spacing: 8) {
						Image(systemName: "checkmark.circle.fill")
							.foregroundStyle(.tint)
						Text(taskName)
						Spacer()
						if count > 1 {
							Text("×\(count)")
						}
					}
				}
			}
		}
		.padding(10)
		.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
		.shadow(radius: 4, y: 2)
		.accessibilityElement(children: .combine)
	}

	// MARK: - Accessibility

	private var accessibilityValue: String {
		let total = dataPoints.reduce(0) { $0 + $1.completedCount }
		return "\(total) completions in the last 7 days"
	}
}
