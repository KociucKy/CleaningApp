import Foundation

// MARK: - OnbProgressStage

enum OnbProgressStage: Int, CaseIterable {
    case welcome
    case roomSelection
    case taskSelection
    case notifications
    case paywall
    case completed

    // MARK: - Properties

    var accessibilityName: LocalizedStringResource {
        switch self {
        case .welcome:
            "onb_progress.stage.welcome"
        case .roomSelection:
            "onb_progress.stage.room_selection"
        case .taskSelection:
            "onb_progress.stage.task_selection"
        case .notifications:
            "onb_progress.stage.notifications"
        case .paywall:
            "onb_progress.stage.paywall"
        case .completed:
            "onb_progress.stage.completed"
        }
    }

    var stepNumber: Int {
        rawValue + 1
    }

    var totalSteps: Int {
        Self.allCases.count
    }
}
