import Foundation

// MARK: - CleaningScheduleCoordinatorError

@MainActor
enum CleaningScheduleCoordinatorError: Error {
    case scheduledTaskNotFound
    case scheduledTaskIsNotPlanned
    case roomTaskNotFound
    case couldNotCalculateSuccessorDate
}
