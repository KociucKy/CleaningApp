import Foundation

// MARK: - CompletionChartDataPoint

struct CompletionChartDataPoint: Identifiable {
    // MARK: - Properties

    let date: Date
    let completedCount: Int

    var id: Date {
        date
    }
}
