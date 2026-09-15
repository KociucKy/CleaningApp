import Foundation

// MARK: - CompletionTrendServicing

@MainActor
protocol CompletionTrendServicing {
    func makeCompletionTrend(
        from completedTasks: [CompletedTask],
        tasks: [RoomTask],
        range: CompletionTrendRange
    ) -> [CompletionChartDataPoint]
}

// MARK: - CompletionTrendService

@MainActor
final class CompletionTrendService: CompletionTrendServicing {
    // MARK: - Methods

    func makeCompletionTrend(
        from completedTasks: [CompletedTask],
        tasks: [RoomTask],
        range: CompletionTrendRange
    ) -> [CompletionChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let rangeStartDate = calendar.date(
            byAdding: .day,
            value: -(range.days - 1),
            to: today
        ) ?? today
        let startDate: Date = {
            guard range == .oneYear else {
                return rangeStartDate
            }

            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) ?? today
            return calendar.date(
                from: calendar.dateComponents([.year, .month], from: oneYearAgo)
            ) ?? oneYearAgo
        }()

        let dates: [Date] = {
            switch range {
            case .sevenDays, .thirtyDays:
                return (0..<range.days).compactMap {
                    calendar.date(byAdding: .day, value: $0, to: startDate)
                }
            case .ninetyDays:
                return (0...12).compactMap {
                    calendar.date(byAdding: .weekOfYear, value: $0, to: startDate)
                }
            case .oneYear:
                return (0...12).compactMap {
                    calendar.date(byAdding: .month, value: $0, to: startDate)
                }
            }
        }()

        var completionsByBucket = [Date: [CompletedTask]]()
        for completion in completedTasks
            where completion.completedAt >= startDate && completion.completedAt <= now {
            if let bucket = completionBucket(
                for: completion.completedAt,
                range: range,
                startDate: startDate,
                calendar: calendar
            ) {
                completionsByBucket[bucket, default: []].append(completion)
            }
        }

        let taskNamesByID = Dictionary(
            uniqueKeysWithValues: tasks.map { ($0.id, $0.name) }
        )

        return dates.map { date in
            let completions = completionsByBucket[date] ?? []
            let taskCounts = completions.reduce(into: [String: Int]()) { counts, completion in
                let taskName = taskNamesByID[completion.taskId] ?? "Unknown task"
                counts[taskName, default: 0] += 1
            }

            return CompletionChartDataPoint(
                date: date,
                completedCount: completions.count,
                taskCounts: taskCounts
            )
        }
    }

    // MARK: - Private

    private func completionBucket(
        for date: Date,
        range: CompletionTrendRange,
        startDate: Date,
        calendar: Calendar
    ) -> Date? {
        switch range {
        case .sevenDays, .thirtyDays:
            return calendar.startOfDay(for: date)
        case .ninetyDays:
            let weeks = calendar.dateComponents(
                [.weekOfYear],
                from: startDate,
                to: date
            ).weekOfYear ?? 0
            return calendar.date(byAdding: .weekOfYear, value: weeks, to: startDate)
        case .oneYear:
            let months = calendar.dateComponents(
                [.month],
                from: startDate,
                to: date
            ).month ?? 0
            return calendar.date(byAdding: .month, value: months, to: startDate)
        }
    }
}
