import Foundation

// MARK: - SchedulingFrequencyRule

@MainActor
enum SchedulingFrequencyRule: Equatable {
    case intervalDays(Int)
    case weeklyQuota(Int)
    case intervalWeeks(Int)
    case monthlyQuota(Int)
    case intervalMonths(Int)
}
