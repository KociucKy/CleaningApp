import Charts
import SwiftUI

struct RoomsDetailsCompletionChartView: View {
	// MARK: - Properties

	let dataPoints: [CompletionChartDataPoint]
	let range: CompletionTrendRange

	@State private var selectedDate: Date?

	private var maximumCount: Int {
		max(dataPoints.map(\.completedCount).max() ?? 0, 1)
	}

	private var completionCounts: [Int] {
		dataPoints.map(\.completedCount)
	}

	private var xAxisDates: [Date] {
		switch range {
		case .sevenDays:
			dataPoints.map(\.date)
		case .thirtyDays:
			dataPoints.enumerated().compactMap { index, dataPoint in
				index.isMultiple(of: 5) ? dataPoint.date : nil
			}
		case .ninetyDays, .oneYear:
			dataPoints.enumerated().compactMap { index, dataPoint in
				index.isMultiple(of: 2) || index == dataPoints.count - 1
					? dataPoint.date
					: nil
			}
		}
	}

	private var xAxisLabelFormat: Date.FormatStyle {
		switch range {
		case .sevenDays:
			.dateTime.weekday(.abbreviated)
		case .thirtyDays, .ninetyDays:
			.dateTime.month(.abbreviated).day()
		case .oneYear:
			.dateTime.month(.abbreviated)
		}
	}

	private var xAxisUnit: Calendar.Component {
		switch range {
		case .sevenDays, .thirtyDays:
			.day
		case .ninetyDays:
			.weekOfYear
		case .oneYear:
			.month
		}
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
		return dataPoints.min {
			abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
		}
	}

	// MARK: - Body

	var body: some View {
		Chart(dataPoints) { dataPoint in
			BarMark(
				x: .value(String(localized: "chart.axis.day", defaultValue: "Day"), dataPoint.date, unit: xAxisUnit),
				y: .value(String(localized: "chart.axis.completed", defaultValue: "Completed"), dataPoint.completedCount)
			)
			.foregroundStyle(markGradient)
		}
		.chartYScale(domain: 0 ... maximumCount)
		.chartXAxis {
			AxisMarks(values: xAxisDates) { _ in
				AxisGridLine()
				AxisTick()
				AxisValueLabel(format: xAxisLabelFormat)
			}
		}
		.chartYAxis {
			AxisMarks(position: .leading, values: .stride(by: 1))
		}
		.chartYAxisLabel(position: .leading) {
			Text(String(localized: "chart.axis.finished_tasks", defaultValue: "Finished tasks"))
				.rotationEffect(.degrees(180))
		}
		.chartXSelection(value: $selectedDate)
		.animation(.easeInOut(duration: 0.35), value: completionCounts)
		.chartOverlay { proxy in
			GeometryReader { geometry in
				if let selectedDataPoint,
				   let xPosition = proxy.position(forX: selectedDataPoint.date)
				{
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
		.accessibilityValue(accessibilityValue)
	}

	// MARK: - Views

	private func selectedDayView(for dataPoint: CompletionChartDataPoint) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(selectedPeriodTitle(for: dataPoint.date))
				.font(.headline)

			if dataPoint.taskCounts.isEmpty {
				Text(String(localized: "chart.empty.no_tasks_finished", defaultValue: "No tasks finished"))
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
							Text(verbatim: "×\(count)")
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

	private func selectedPeriodTitle(for date: Date) -> String {
		switch range {
		case .sevenDays, .thirtyDays:
			date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
		case .ninetyDays:
			"\(String(localized: "chart.period.week_of", defaultValue: "Week of")) \(date.formatted(.dateTime.month(.abbreviated).day()))"
		case .oneYear:
			date.formatted(.dateTime.month(.wide).year())
		}
	}

	// MARK: - Accessibility

	private var accessibilityValue: String {
		let total = dataPoints.reduce(0) { $0 + $1.completedCount }
		return "\(String(localized: "chart.accessibility.completions_in_selected_range", defaultValue: "Completions in selected range")): \(total)"
	}
}
