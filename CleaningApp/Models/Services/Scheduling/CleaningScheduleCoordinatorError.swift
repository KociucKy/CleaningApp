import Foundation

// MARK: - CleaningScheduleCoordinatorError

@MainActor
enum CleaningScheduleCoordinatorError: Error {
    case scheduledTaskNotFound
    case scheduledTaskIsNotPlanned
    case scheduledTaskIsNotCompleted
    case scheduledTaskIsNotSkipped
    case completedTaskHistoryNotFound
    case skippedTaskHistoryNotFound
    case roomTaskNotFound
    case couldNotCalculateSuccessorDate
}
