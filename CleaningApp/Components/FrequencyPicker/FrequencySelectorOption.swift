import Foundation

// MARK: - FrequencySelectorOption

enum FrequencySelectorOption: String, CaseIterable, Identifiable {
    case daily
    case everyXDays
    case timesPerWeek
    case everyXWeeks
    case timesPerMonth
    case everyXMonths

    // MARK: - Properties

    var id: String {
        rawValue
    }

    var menuTitle: LocalizedStringResource {
        switch self {
        case .daily:
            "frequency.daily"
        case .everyXDays:
            "Every X days"
        case .timesPerWeek:
            "X times per week"
        case .everyXWeeks:
            "Every X weeks"
        case .timesPerMonth:
            "X times per month"
        case .everyXMonths:
            "Every X months"
        }
    }

    var defaultFrequency: Frequency {
        switch self {
        case .daily:
            .daily
        case .everyXDays:
            .everyXDays(2)
        case .timesPerWeek:
            .timesPerWeek(1)
        case .everyXWeeks:
            .everyXWeeks(2)
        case .timesPerMonth:
            .timesPerMonth(2)
        case .everyXMonths:
            .everyXMonths(2)
        }
    }

    var countRange: ClosedRange<Int>? {
        switch self {
        case .daily:
            nil
        case .everyXDays:
            2 ... 365
        case .timesPerWeek:
            1 ... 7
        case .everyXWeeks:
            2 ... 52
        case .timesPerMonth:
            1 ... 31
        case .everyXMonths:
            2 ... 24
        }
    }

    // MARK: - Init

    init(frequency: Frequency) {
        switch frequency {
        case .daily:
            self = .daily
        case .everyOtherDay, .everyXDays:
            self = .everyXDays
        case .timesPerWeek:
            self = .timesPerWeek
        case .everyOtherWeek, .everyXWeeks:
            self = .everyXWeeks
        case .monthly, .timesPerMonth:
            self = .timesPerMonth
        case .quarterly, .biannually, .yearly, .everyXMonths:
            self = .everyXMonths
        }
    }

    // MARK: - Methods

    func count(for frequency: Frequency) -> Int? {
        switch (self, frequency) {
        case (.everyXDays, .everyOtherDay):
            2
        case let (.everyXDays, .everyXDays(count)),
             let (.timesPerWeek, .timesPerWeek(count)),
             let (.everyXWeeks, .everyXWeeks(count)),
             let (.timesPerMonth, .timesPerMonth(count)),
             let (.everyXMonths, .everyXMonths(count)):
            count
        case (.everyXWeeks, .everyOtherWeek):
            2
        case (.timesPerMonth, .monthly):
            1
        case (.everyXMonths, .quarterly):
            3
        case (.everyXMonths, .biannually):
            6
        case (.everyXMonths, .yearly):
            12
        default:
            nil
        }
    }

    func frequency(for count: Int) -> Frequency {
        let boundedCount = boundedCount(from: count)

        switch self {
        case .daily:
            return .daily
        case .everyXDays:
            return .everyXDays(boundedCount)
        case .timesPerWeek:
            return .timesPerWeek(boundedCount)
        case .everyXWeeks:
            return .everyXWeeks(boundedCount)
        case .timesPerMonth:
            return .timesPerMonth(boundedCount)
        case .everyXMonths:
            return .everyXMonths(boundedCount)
        }
    }

    // MARK: - Private

    private func boundedCount(from count: Int) -> Int {
        guard let countRange else { return 0 }
        return min(max(count, countRange.lowerBound), countRange.upperBound)
    }
}
