import Foundation

// MARK: - SchedulingService

@MainActor
final class SchedulingService {
    // MARK: - Methods

    func makeHorizon(today: Date, calendar: Calendar) -> SchedulingHorizon {
        let startDate = calendar.startOfDay(for: today)
        let weekday = calendar.component(.weekday, from: startDate)
        let daysUntilSunday = (8 - weekday) % 7
        let days = (0 ... daysUntilSunday).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDate)
        }
        let endDate = days.last ?? startDate

        return SchedulingHorizon(
            startDate: startDate,
            endDate: endDate,
            days: days
        )
    }
}
