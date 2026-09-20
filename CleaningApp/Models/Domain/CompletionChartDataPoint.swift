import Foundation

// MARK: - CompletionChartDataPoint

struct CompletionChartDataPoint: Identifiable {
    // MARK: - Properties

    let date: Date
    let completedCount: Int
    let taskCounts: [String: Int]

    var id: Date {
        date
    }
}
