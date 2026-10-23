import Foundation

// MARK: - ScheduleMutation

@MainActor
struct ScheduleMutation: Equatable {
    // MARK: - Properties

    let occurrencesToCreate: [ScheduledTask]
    let occurrencesToUpdate: [ScheduledTask]

    // MARK: - Init

    init(
        occurrencesToCreate: [ScheduledTask] = [],
        occurrencesToUpdate: [ScheduledTask] = []
    ) {
        self.occurrencesToCreate = occurrencesToCreate
        self.occurrencesToUpdate = occurrencesToUpdate
    }
}
