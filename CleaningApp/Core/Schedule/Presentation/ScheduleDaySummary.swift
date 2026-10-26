import Foundation

// MARK: - ScheduleDaySummary

@MainActor
struct ScheduleDaySummary: Equatable {
    // MARK: - Properties

    let weekdayName: String
    let completionText: String
    let taskDescription: String
    let completedTaskCount: Int
    let progressTotal: Int

    // MARK: - Init

    init(
        weekdayName: String,
        completionText: String,
        taskDescription: String,
        completedTaskCount: Int,
        progressTotal: Int
    ) {
        self.weekdayName = weekdayName
        self.completionText = completionText
        self.taskDescription = taskDescription
        self.completedTaskCount = completedTaskCount
        self.progressTotal = progressTotal
    }
}
