import Foundation

// MARK: - CleaningScheduleCoordinatorError

@MainActor
enum CleaningScheduleCoordinatorError: Error {
    case scheduledTaskNotFound
    case scheduledTaskIsNotPlanned
    case scheduledTaskIsNotSkipped
    case skippedTaskHistoryNotFound
    case roomTaskNotFound
    case couldNotCalculateSuccessorDate
}
