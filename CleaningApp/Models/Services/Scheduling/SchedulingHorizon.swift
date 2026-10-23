import Foundation

// MARK: - SchedulingHorizon

@MainActor
struct SchedulingHorizon: Equatable {
    // MARK: - Properties

    let startDate: Date
    let endDate: Date
    let days: [Date]
}
