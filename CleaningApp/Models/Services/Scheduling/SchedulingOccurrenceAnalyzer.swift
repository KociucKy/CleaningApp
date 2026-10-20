import Foundation

// MARK: - SchedulingOccurrenceAnalyzer

@MainActor
final class SchedulingOccurrenceAnalyzer {
    // MARK: - Methods

    func analyze(
        scheduledTasks: [ScheduledTask],
        horizon: SchedulingHorizon
    ) -> SchedulingOccurrenceAnalysis {
        SchedulingOccurrenceAnalysis(
            preservedOccurrences: sorted(
                scheduledTasks.filter {
                    $0.status == .planned
                        && $0.scheduledDate >= horizon.startDate
                        && $0.scheduledDate <= horizon.endDate
                }
            ),
            overdueOccurrences: sorted(
                scheduledTasks.filter {
                    $0.status == .planned && $0.scheduledDate < horizon.startDate
                }
            ),
            backlogOccurrences: sorted(
                scheduledTasks.filter { occurrence in
                    occurrence.status == .postponed
                        && !scheduledTasks.contains {
                            $0.status == .planned
                                && $0.sourceOccurrenceId == occurrence.id
                        }
                }
            )
        )
    }

    // MARK: - Private

    private func sorted(_ occurrences: [ScheduledTask]) -> [ScheduledTask] {
        occurrences.sorted {
            if $0.scheduledDate != $1.scheduledDate {
                return $0.scheduledDate < $1.scheduledDate
            }
            return $0.id.uuidString < $1.id.uuidString
        }
    }
}
